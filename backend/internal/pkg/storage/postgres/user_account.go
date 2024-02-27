package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
)

func (db *DB) GetUserAccount(userAccountID types.UserAccountID) (types.UserAccount, error) {
	var userAccount types.UserAccount

	query := `
		SELECT ua.id, ua.username, ua.name, ua.created_at, ua.level, ua.profile_picture, ua.bodyweight
		FROM user_account ua
		WHERE ua.id = $1;
	`

	err := db.pool.QueryRow(query, userAccountID).Scan(
		&userAccount.ID,
		&userAccount.Username,
		&userAccount.Name,
		&userAccount.CreatedAt,
		&userAccount.Level,
		&userAccount.ProfilePicture,
		&userAccount.Bodyweight)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return types.UserAccount{}, errors.New("user not found")
		}
		return types.UserAccount{}, err
	}

	return userAccount, nil
}
