package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
	"strconv"
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

func (db *DB) GetUserAccountInformations(userAccountID int, params map[string]any) ([]any, error) {
	conditionParamIndex := 2
	var conditionParams []any
	var fromConditions []string
	var whereConditions []string
	var orderConditions []string

	query := `
		SELECT ua.id, ua.username, ua.name, ua.created_at, ua.level, ua.profile_picture
	`

	fromConditions = append(fromConditions, " FROM user_account ua")
	whereConditions = append(whereConditions, " ua.id != $1")
	conditionParams = append(conditionParams, userAccountID)

	_, exists := params["gymID"]
	if exists {
		query += `, 
			(SELECT w.starttime 
				FROM workout w 
				WHERE w.endtime IS NULL AND w.starttime IS NOT NULL AND w.user_id = ua.id) AS starttime, 
			(SELECT AVG(EXTRACT(EPOCH FROM (endtime - starttime)))
				FROM workout w
				WHERE w.endtime IS NOT NULL AND w.starttime IS NOT NULL) AS avg_workout_duration
		`

		whereConditions = append(whereConditions, " w.gym_id = $"+strconv.Itoa(conditionParamIndex)+" AND w.starttime IS NOT NULL")
		conditionParams = append(conditionParams, params["gymID"])
		fromConditions = append(fromConditions, " LEFT JOIN workout w ON w.user_id = ua.id")
		orderConditions = append(orderConditions, " starttime DESC")
		conditionParamIndex++

		_, exists = params["isWorkingOut"]
		if exists {
			whereConditions = append(whereConditions, " w.endtime IS NULL")
		}
	}

	_, exists = params["isFriend"]
	if exists {
		fromConditions = append(fromConditions, " LEFT JOIN friendship f ON ua.id = f.requestor_id OR ua.id = f.requested_id")
		whereConditions = append(whereConditions, " f.is_accepted = $"+strconv.Itoa(conditionParamIndex))
		conditionParams = append(conditionParams, params["isFriend"])
		conditionParamIndex++

		whereConditions = append(whereConditions, " ($1 = f.requestor_id OR $1 = f.requested_id)")
		orderConditions = append(orderConditions, " f.created_at DESC")
	}

	_, exists = params["hasRequest"]
	if exists {
		fromConditions = append(fromConditions, " LEFT JOIN friendship f ON ua.id = f.requestor_id OR ua.id = f.requested_id")
		whereConditions = append(whereConditions, " f.is_accepted != $"+strconv.Itoa(conditionParamIndex)+" AND ($1 = f.requestor_id OR $1 = f.requested_id)")
		conditionParams = append(conditionParams, params["hasRequest"])
		conditionParamIndex++
	}

	_, exists = params["keyword"]
	if exists {
		whereConditions = append(whereConditions, " (LOWER(ua.username) LIKE '%' || LOWER($"+strconv.Itoa(conditionParamIndex)+") || '%' OR LOWER(ua.name) LIKE '%' || LOWER($"+strconv.Itoa(conditionParamIndex)+") || '%')")
		conditionParams = append(conditionParams, params["keyword"])
		conditionParamIndex++
	}

	for i := 0; i < len(fromConditions); i++ {
		query += fromConditions[i]
	}

	for i := 0; i < len(whereConditions); i++ {
		if i > 0 {
			query += " AND"
		} else {
			query += " WHERE"
		}
		query += whereConditions[i]
	}

	for i := 0; i < len(orderConditions); i++ {
		if i > 0 {
			query += ","
		} else {
			query += " ORDER BY"
		}
		query += orderConditions[i]
	}

	query += ";"

	//Execute Query
	var informations []any

	rows, err := db.pool.Query(query, conditionParams...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var information types.UserAccountInformation

		if _, exists := params["gymID"]; exists {
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
		} else {
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
		}
		informations = append(informations, information)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return informations, nil
}
