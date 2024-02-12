package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
)

func (db DB) CreateUserAccount(createUserRequest types.CreateUserRequest) (types.UserAccount, error) {
	tx, err := db.pool.Begin()
	if err != nil {
		return types.UserAccount{}, err
	}
	defer func() {
		if err != nil {
			tx.Rollback()
			return
		}
		err = tx.Commit()
	}()

	query := `
        INSERT INTO user_account (username, name, publicKey, encryptedPrivateKey, randomSaltOne, randomSaltTwo, level, created_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
        RETURNING id, created_at;
    `
	var userAccount types.UserAccount
	userAccount.Username = createUserRequest.Username
	userAccount.Name = createUserRequest.Name
	userAccount.PublicKey = createUserRequest.PublicKey
	userAccount.EncryptedPrivateKey = createUserRequest.EncryptedPrivateKey
	userAccount.RandomSaltOne = createUserRequest.RandomSaltOne
	userAccount.RandomSaltTwo = createUserRequest.RandomSaltTwo
	userAccount.Level = 1

	err = tx.QueryRow(query, createUserRequest.Username, createUserRequest.Name, createUserRequest.PublicKey, createUserRequest.EncryptedPrivateKey, createUserRequest.RandomSaltOne, createUserRequest.RandomSaltTwo, 1).Scan(&userAccount.ID, &userAccount.CreatedAt)
	if err != nil {
		return types.UserAccount{}, err
	}

	err = db.CreateUserSettings(tx, userAccount.ID)
	if err != nil {
		return types.UserAccount{}, err
	}

	return userAccount, nil
}

func (db DB) GetUsernameAvailability(username string) (bool, error) {
	var userCount int
	query := `
        SELECT COUNT(*) AS user_count
        FROM user_account
        WHERE username = $1;
    `
	err := db.pool.QueryRow(query, username).Scan(&userCount)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return true, nil
		}
		return false, err
	}
	return userCount == 0, nil
}

func (db DB) GetSignUpResult(username string) (types.SignUpResult, error) {
	query := `
        SELECT u.public_key, u.encrypted_private_key, u.random_salt_one, u.random_salt_two
        FROM user_account AS u
        WHERE username = $1;
    `

	var signUpResult types.SignUpResult
	err := db.pool.QueryRow(query, username).Scan(&signUpResult.PublicKey, &signUpResult.EncryptedPrivateKey, &signUpResult.RandomSaltOne, &signUpResult.RandomSaltTwo)
	if err != nil {
		return types.SignUpResult{}, err
	}
	return signUpResult, nil
}
