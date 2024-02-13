package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
	"time"

	"github.com/dgrijalva/jwt-go"
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
	var userAccount types.UserAccount
	userAccount.Username = createUserRequest.Username
	userAccount.Name = createUserRequest.Name
	userAccount.Password = createUserRequest.Password
	userAccount.Level = 1

	err = tx.QueryRow(query, createUserRequest.Username, createUserRequest.Name, createUserRequest.Password, 1).Scan(&userAccount.ID, &userAccount.CreatedAt)
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
	var storedPassword string
	query := `
        SELECT password
        FROM user_account
        WHERE username = $1;
    `
	err := db.pool.QueryRow(query, username).Scan(&storedPassword)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return "", errors.New("user not found")
		}
		return "", err
	}

	if password != storedPassword {
		return "", errors.New("incorrect password")
	}

	token, err := CreateJWT(username)
	if err != nil {
		return "", err
	}

	return token, nil
}

var (
	jwtKey = []byte("your_secret_key") // Change this to your own secret key
)

func CreateJWT(username string) (string, error) {
	token := jwt.New(jwt.SigningMethodHS256)
	claims := token.Claims.(jwt.MapClaims)

	claims["authorized"] = true
	claims["user_id"] = "user123"
	claims["exp"] = time.Now().AddDate(1, 0, 0).Unix()

	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}
