package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
)

func (db *DB) GetUserAccountInformation(userAccountID int) (types.UserAccountInformation, error) {
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

	_, err := db.pool.Exec(query,
		args...,
	)
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

	_, err := db.pool.Exec(query,
		userAccountID,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("user not found")
		}
		return err
	}

	return nil
}

func (db *DB) GetUserAccountInformations(userAccountID int, params map[string]any) ([]any, error) {
	_, exists := params["gymID"]
	if !exists {
		var informations []any

		query := `
				SELECT ua.id, ua.username, ua.name, ua.created_at, ua.level, ua.profile_picture
				FROM user_account ua
				LEFT JOIN friendship f ON ua.id = f.requestor_id OR ua.id = f.requested_id
				WHERE ua.id != $1 AND (f.is_accepted = $2 
				OR ($2 = FALSE AND NOT EXISTS (
					SELECT 1
					FROM friendship f
					WHERE (ua.id = f.requestor_id OR ua.id = f.requested_id))))
				AND (LOWER(ua.username) LIKE '%' || LOWER($3) || '%' OR LOWER(ua.name) LIKE '%' || LOWER($3) || '%')
				ORDER BY f.is_accepted ASC, f.created_at DESC;
			`

		rows, err := db.pool.Query(query, userAccountID, params["isFriend"], params["keyword"])
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

	var informations []any

	query := `
		SELECT
			ua.id,
			ua.username,
			ua.name,
			ua.profile_picture,
			(SELECT w.starttime
			FROM workout w
			WHERE w.endtime IS NULL AND w.starttime IS NOT NULL AND w.user_id = ua.id) AS starttime,
			(SELECT AVG(EXTRACT(EPOCH FROM (endtime - starttime)))
			FROM workout w
			WHERE w.endtime IS NOT NULL AND w.starttime IS NOT NULL) AS avg_workout_duration
		FROM
			user_account ua
		LEFT JOIN
			friendship f ON ua.id = f.requestor_id OR ua.id = f.requested_id
		LEFT JOIN
			workout w ON w.user_id = ua.id
		WHERE
			ua.id != $1 AND f.is_accepted = $2 AND w.gym_id = $3 AND w.starttime IS NOT NULL
		ORDER BY
			starttime DESC;
	`

	rows, err := db.pool.Query(query, userAccountID, params["isFriend"], params["gymID"])
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var information types.UserAccountWorkoutInformation
		err := rows.Scan(
			&information.UserAccountID,
			&information.Username,
			&information.Name,
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
