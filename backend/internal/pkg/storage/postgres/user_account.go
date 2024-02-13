package postgres

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"database/sql"
	"encoding/pem"
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
        INSERT INTO user_account (username, name, public_key, encrypted_private_key, random_salt_one, random_salt_two, level, created_at)
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

func (db DB) GetVerificationCode(publicKey []byte) ([]byte, error) {
	encryptedVerificationCode, err := GenerateVerificationCode(publicKey, db)
	if err != nil {
		return []byte{}, err
	}

	return encryptedVerificationCode, nil
}

func GenerateVerificationCode(publicKey []byte, db DB) ([]byte, error) {
	salt := make([]byte, 16)
	_, err := rand.Read(salt)
	if err != nil {
		return nil, err
	}

	query := `
        UPDATE user_account
        SET verification_code = $1
        WHERE id = 1;
    `

	_, err = db.pool.Exec(query, publicKey)
	if err != nil {
		return nil, err
	}

	encryptedSalt, err := EncryptSalt(salt, publicKey)
	if err != nil {
		return nil, err
	}

	return encryptedSalt, nil
}

func EncryptSalt(salt []byte, pubKey []byte) ([]byte, error) {
	block, _ := pem.Decode(pubKey)
	if block == nil {
		return nil, errors.New("failed to parse PEM block containing the public key")
	}

	pub, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return nil, err
	}

	rsaPubKey, ok := pub.(*rsa.PublicKey)
	if !ok {
		return nil, errors.New("provided key is not an RSA public key")
	}

	encrypted, err := rsa.EncryptPKCS1v15(rand.Reader, rsaPubKey, salt)
	if err != nil {
		return nil, err
	}

	return encrypted, nil
}
