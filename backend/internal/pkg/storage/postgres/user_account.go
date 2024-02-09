package postgres

import "flexus/internal/types"

func (db DB) CreateUserAccount(createUserRequest types.CreateUserRequest) (types.UserAccount, error) {
	query := `
		INSERT INTO user_account (username, name, publicKey, encryptedPrivateKey, randomSaltOne, randomSaltTwo, level, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
		RETURNING id, created_at;
	`
	var userAccount types.UserAccount
	userAccount.Username = createUserRequest.Username
	userAccount.Name = createUserRequest.Name
	userAccount.EncryptedPrivateKey = createUserRequest.EncryptedPrivateKey
	userAccount.RandomSaltOne = createUserRequest.RandomSaltOne
	userAccount.RandomSaltOne = createUserRequest.RandomSaltOne
	userAccount.RandomSaltTwo = createUserRequest.RandomSaltTwo
	userAccount.Level = 1

	err := db.pool.QueryRow(query, createUserRequest.Username, createUserRequest.Name, createUserRequest.EncryptedPrivateKey, createUserRequest.RandomSaltOne, createUserRequest.RandomSaltTwo, 1, 80).Scan(&userAccount.ID, &userAccount.CreatedAt)
	if err != nil {
		return types.UserAccount{}, err
	}

	return userAccount, err
}
