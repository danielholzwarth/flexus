package postgres

import (
	"database/sql"
	"errors"
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

func (db DB) GetLoginUser(username string, password string) (types.UserAccount, error) {
	var userAccount types.UserAccount

	query := `
        SELECT *
        FROM user_account
        WHERE username = $1;
    `

	err := db.pool.QueryRow(query, username).Scan(
		&userAccount.ID,
		&userAccount.Username,
		&userAccount.Name,
		&userAccount.Password,
		&userAccount.CreatedAt,
		&userAccount.Level,
		&userAccount.ProfilePicture,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return types.UserAccount{}, errors.New("user not found")
		}
		return types.UserAccount{}, err
	}

	if userAccount.ProfilePicture == nil {
		userAccount.ProfilePicture = new([]byte)
	}

	err = bcrypt.CompareHashAndPassword([]byte(userAccount.Password), []byte(password))
	if err != nil {
		return types.UserAccount{}, errors.New("incorrect password")
	}

	return userAccount, nil
}

func (db DB) ValidatePasswordByID(userAccountID int, password string) error {
	var storedPassword []byte

	query := `
        SELECT password
        FROM user_account
        WHERE id = $1;
    `

	err := db.pool.QueryRow(query, userAccountID).Scan(&storedPassword)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("user not found")
		}
		return err
	}

	err = bcrypt.CompareHashAndPassword([]byte(storedPassword), []byte(password))
	return err
}
