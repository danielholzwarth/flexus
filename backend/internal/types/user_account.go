package types

import "time"

type UserAccountID uint

type UserAccount struct {
	ID             UserAccountID `json:"id"`
	Username       string        `json:"username"`
	Name           string        `json:"name"`
	Password       []byte        `json:"password"`
	CreatedAt      time.Time     `json:"createdAt"`
	Level          int           `json:"level"`
	ProfilePicture string        `json:"profilePicture"`
	Bodyweight     int           `json:"bodyweight"`
	GenderID       int           `json:"genderID"`
}

type CreateUserRequest struct {
	Username string `json:"username"`
	Name     string `json:"name"`
	Password string `json:"password"`
}

type LoginUserRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}
