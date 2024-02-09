package types

import "time"

type UserAccountID uint

type UserAccount struct {
	ID                  UserAccountID `json:"id"`
	Username            string        `json:"username"`
	Name                string        `json:"name"`
	PublicKey           string        `json:"publicKey"`
	EncryptedPrivateKey string        `json:"encryptedPrivateKey"`
	RandomSaltOne       string        `json:"randomSaltOne"`
	RandomSaltTwo       string        `json:"randomSaltTwo"`
	CreatedAt           time.Time     `json:"createdAt"`
	Level               int           `json:"level"`
	ProfilePicture      string        `json:"profilePicture"`
	Bodyweight          int           `json:"bodyweight"`
	GenderID            int           `json:"genderID"`
}
