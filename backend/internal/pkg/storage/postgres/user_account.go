package postgres

import "flexus/internal/types"

func (db DB) CreateUserAccount(name string) (types.UserAccount, error) {
	query := `
		INSERT INTO user_account (username, name, password, level, created_at, bodyweight)
		VALUES ($1, $2, $3, $4, NOW(), $5)
		RETURNING id, created_at;
	`
	var userAccount types.UserAccount
	userAccount.Name = name

	err := db.pool.QueryRow(query, "username", name, "password", 1, 80).Scan(&userAccount.ID, &userAccount.CreatedAt)
	if err != nil {
		return types.UserAccount{}, err
	}

	return userAccount, err
}
