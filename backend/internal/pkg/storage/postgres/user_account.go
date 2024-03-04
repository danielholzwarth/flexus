package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
)

func (db *DB) GetUserAccountInformation(userAccountID types.UserAccountID) (types.UserAccountInformation, error) {
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

func (db *DB) PatchUserAccount(columnName string, value any, userAccountID types.UserAccountID) error {
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

func (db *DB) DeleteUserAccount(userAccountID types.UserAccountID) error {
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

func (db *DB) GetUserAccountInformations(userAccountID types.UserAccountID, keyword string, isFriends bool) ([]types.UserAccountInformation, error) {
	var userAccounts []types.UserAccountInformation

	query := `
		SELECT ua.id, ua.username, ua.name, ua.created_at, ua.level, ua.profile_picture
		FROM user_account ua
		LEFT JOIN friendship f ON ua.id = f.requestor_id OR ua.id = f.requested_id
		WHERE ua.id != $1 AND f.is_accepted = $2 
		OR ($2 = FALSE AND NOT EXISTS (
			SELECT 1
			FROM friendship f
			WHERE (ua.id = f.requestor_id OR ua.id = f.requested_id)))
		AND (LOWER(ua.username) LIKE '%' || LOWER($3) || '%' OR LOWER(ua.name) LIKE '%' || LOWER($3) || '%')
		ORDER BY f.is_accepted ASC, f.created_at DESC;
	`

	rows, err := db.pool.Query(query, userAccountID, isFriends, keyword)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var userAccount types.UserAccountInformation
		err := rows.Scan(
			&userAccount.UserAccountID,
			&userAccount.Username,
			&userAccount.Name,
			&userAccount.CreatedAt,
			&userAccount.Level,
			&userAccount.ProfilePicture,
		)
		if err != nil {
			return nil, err
		}
		userAccounts = append(userAccounts, userAccount)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return userAccounts, nil
}
