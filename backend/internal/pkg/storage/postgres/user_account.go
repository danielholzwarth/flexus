package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
)

func (db *DB) GetUserAccountFromUserID(userAccountID int) (types.UserAccountInformation, error) {
	var userAccount types.UserAccountInformation

	query := `
		SELECT ua.id, ua.username, ua.name, ua.created_at, ua.level, ua.profile_picture
		FROM user_account ua
		WHERE ua.id = $1;
	`

	err := db.pool.QueryRow(query, userAccountID).Scan(
		&userAccount.UserAccountID,
		&userAccount.Username,
		&userAccount.Name,
		&userAccount.CreatedAt,
		&userAccount.Level,
		&userAccount.ProfilePicture)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return types.UserAccountInformation{}, errors.New("user not found")
		}
		return types.UserAccountInformation{}, err
	}

	return userAccount, nil
}

func (db *DB) PatchUserAccount(columnName string, value any, userAccountID int) error {
	var query string
	var args []interface{}

	if value == nil {
		query = `
			UPDATE user_account
			SET ` + columnName + ` = NULL
			WHERE id = $1;
		`
		args = []interface{}{userAccountID}
	} else {
		query = `
			UPDATE user_account
			SET ` + columnName + ` = $1
			WHERE id = $2;
		`
		args = []interface{}{value, userAccountID}
	}

	_, err := db.pool.Exec(query, args...)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("user not found")
		}
		return err
	}

	return nil
}

func (db *DB) DeleteUserAccount(userAccountID int) error {
	query := `
		DELETE 
		FROM user_account
		WHERE id = $1;
	`

	_, err := db.pool.Exec(query, userAccountID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("user not found")
		}
		return err
	}

	return nil
}

func (db *DB) GetUserAccountInformations(userAccountID int, keyword string, isFriend bool, hasRequest bool) ([]any, error) {
	var conditionParams []any
	conditionParams = append(conditionParams, userAccountID)
	conditionParams = append(conditionParams, keyword)

	query := `
		SELECT ua.id, ua.username, ua.name, ua.created_at, ua.level, ua.profile_picture
		FROM user_account ua
	`
	if isFriend && hasRequest {
		// FRIENDS AND REQUESTS
		query += `
			LEFT JOIN friendship f ON ua.id = f.requestor_id OR ua.id = f.requested_id
			INNER JOIN user_settings us ON us.user_id = ua.id
			WHERE ua.id != $1
				AND ((f.requestor_id = $1 AND f.requested_id = ua.id) OR (f.requested_id = $1 AND f.requestor_id = ua.id))
				AND (LOWER(ua.username) LIKE '%' || LOWER($2) || '%' OR LOWER(ua.name) LIKE '%' || LOWER($2) || '%')
			ORDER BY f.is_accepted = FALSE DESC;
		`
	} else if isFriend {
		// FRIENDS
		query += `
			LEFT JOIN friendship f ON ua.id = f.requestor_id OR ua.id = f.requested_id
			INNER JOIN user_settings us ON us.user_id = ua.id
			WHERE ua.id != $1
				AND ((f.requestor_id = $1 AND f.requested_id = ua.id) OR (f.requested_id = $1 AND f.requestor_id = ua.id))
				AND f.is_accepted = TRUE
				AND (LOWER(ua.username) LIKE '%' || LOWER($2) || '%' OR LOWER(ua.name) LIKE '%' || LOWER($2) || '%');
		`
	} else if hasRequest {
		// REQUESTS
		query += `
			LEFT JOIN friendship f ON ua.id = f.requestor_id OR ua.id = f.requested_id
			INNER JOIN user_settings us ON us.user_id = ua.id
			WHERE ua.id != $1
				AND ((f.requestor_id = $1 AND f.requested_id = ua.id) OR (f.requested_id = $1 AND f.requestor_id = ua.id))
				AND f.is_accepted = FALSE
				AND (LOWER(ua.username) LIKE '%' || LOWER($2) || '%' OR LOWER(ua.name) LIKE '%' || LOWER($2) || '%')
			ORDER BY f.is_accepted = FALSE DESC;
		`
	} else {
		//ALL
		query += `
			INNER JOIN user_settings us ON us.user_id = ua.id
			WHERE ua.id != $1
				AND us.is_unlisted = FALSE
				AND (LOWER(ua.username) LIKE '%' || LOWER($2) || '%' OR LOWER(ua.name) LIKE '%' || LOWER($2) || '%');
		`
	}

	rows, err := db.pool.Query(query, conditionParams...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var informations []any

	for rows.Next() {
		var information types.UserAccountInformation

		err := rows.Scan(
			&information.UserAccountID,
			&information.Username,
			&information.Name,
			&information.CreatedAt,
			&information.Level,
			&information.ProfilePicture,
		)
		if err != nil {
			return nil, err
		}

		informations = append(informations, information)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return informations, nil
}

func (db *DB) GetUserAccountsFromGymID(userAccountID int, gymID int, isWorkingOut bool) ([]any, error) {
	query := `
		SELECT DISTINCT ua.id, ua.username, ua.name, ua.created_at, ua.level, ua.profile_picture,
		(SELECT w.starttime 
			FROM workout w 
			WHERE w.gym_id = $1 
			AND w.endtime IS NULL 
			AND w.starttime IS NOT NULL 
			AND w.user_id = ua.id) AS starttime, 
		(SELECT AVG(EXTRACT(EPOCH FROM (endtime - starttime)))
			FROM workout w
			WHERE w.gym_id = $1 
			AND w.endtime IS NOT NULL
			AND w.user_id = ua.id
			AND w.starttime IS NOT NULL) AS avg_workout_duration
		FROM user_account ua
		JOIN workout ON ua.id = workout.user_id
		JOIN friendship ON friendship.requestor_id = ua.id OR friendship.requested_id = ua.id
		WHERE workout.gym_id = $1
		AND workout.endtime IS NULL 
		AND (friendship.requestor_id = $2 OR friendship.requested_id = $2)
		AND friendship.is_accepted = TRUE;

		
	`

	var informations []any

	rows, err := db.pool.Query(query, gymID, userAccountID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var information types.UserAccountInformation

		err := rows.Scan(
			&information.UserAccountID,
			&information.Username,
			&information.Name,
			&information.CreatedAt,
			&information.Level,
			&information.ProfilePicture,
			&information.WorkoutStartTime,
			&information.AverageWorkoutDuration,
		)
		if err != nil {
			return nil, err
		}

		informations = append(informations, information)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return informations, nil
}

func (db *DB) PatchEntireUserAccount(userAccountID int, userAccount types.UserAccount) error {
	query := `
			UPDATE user_account
			SET name = $2, username = $3, level = $4, profile_picture = $5
			WHERE id = $1;
		`

	_, err := db.pool.Exec(query, userAccountID, userAccount.Name, userAccount.Username, userAccount.Level, userAccount.ProfilePicture)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("user not found")
		}
		return err
	}

	return nil
}
