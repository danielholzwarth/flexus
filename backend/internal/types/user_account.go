package types

import "time"

type UserAccountID uint

type UserAccount struct {
	ID                  UserAccountID `json:"id"`
	Username            string        `json:"username"`
	Name                string        `json:"name"`
	PublicKey           []byte        `json:"publicKey"`
	EncryptedPrivateKey []byte        `json:"encryptedPrivateKey"`
	RandomSaltOne       []byte        `json:"randomSaltOne"`
	RandomSaltTwo       []byte        `json:"randomSaltTwo"`
	CreatedAt           time.Time     `json:"createdAt"`
	Level               int           `json:"level"`
	ProfilePicture      string        `json:"profilePicture"`
	Bodyweight          int           `json:"bodyweight"`
	GenderID            int           `json:"genderID"`
}
