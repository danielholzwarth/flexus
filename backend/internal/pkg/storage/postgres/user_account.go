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
	var updateQuery string
	var args []interface{}

	if value == nil {
		updateQuery = `
			UPDATE user_account
			SET ` + columnName + ` = NULL
			WHERE id = $1;
		`
		args = []interface{}{userAccountID}
	} else {
		updateQuery = `
			UPDATE user_account
			SET ` + columnName + ` = $1
			WHERE id = $2;
		`
		args = []interface{}{value, userAccountID}
	}

	_, err := db.pool.Exec(updateQuery,
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
	updateQuery := `
		DELETE 
		FROM user_account
		WHERE id = $1;
	`

	_, err := db.pool.Exec(updateQuery,
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
