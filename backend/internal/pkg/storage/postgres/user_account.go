package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/api/middleware"
	"flexus/internal/types"

	"golang.org/x/crypto/bcrypt"
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
        INSERT INTO user_account (username, name, password, level, created_at)
        VALUES ($1, $2, $3, $4, NOW())
        RETURNING id, created_at;
    `

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(createUserRequest.Password), bcrypt.DefaultCost)
	if err != nil {
		return types.UserAccount{}, err
	}

	var userAccount types.UserAccount
	userAccount.Username = createUserRequest.Username
	userAccount.Name = createUserRequest.Name
	userAccount.Password = hashedPassword
	userAccount.Level = 1

	err = tx.QueryRow(query, createUserRequest.Username, createUserRequest.Name, hashedPassword, 1).Scan(&userAccount.ID, &userAccount.CreatedAt)
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

func (db DB) GetLoginUser(username string, password string) (string, error) {
	var storedPassword []byte
	var userID types.UserAccountID
	query := `
        SELECT id, password
        FROM user_account
        WHERE username = $1;
    `
	err := db.pool.QueryRow(query, username).Scan(&userID, &storedPassword)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return "", errors.New("user not found")
		}
		return "", err
	}

	err = bcrypt.CompareHashAndPassword([]byte(storedPassword), []byte(password))
	if err != nil {
		return "", errors.New("incorrect password")
	}

	token, err := middleware.CreateJWT(userID, username)
	if err != nil {
		return "", err
	}

	return token, nil
}
