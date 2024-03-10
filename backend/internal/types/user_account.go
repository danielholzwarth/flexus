package types

import "time"

type UserAccount struct {
	ID             int       `json:"id"`
	Username       string    `json:"username"`
	Name           string    `json:"name"`
	Password       []byte    `json:"password"`
	CreatedAt      time.Time `json:"createdAt"`
	Level          int       `json:"level"`
	ProfilePicture *[]byte   `json:"profilePicture"`
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

type UserAccountInformation struct {
	UserAccountID          int        `json:"userAccountID"`
	Username               string     `json:"username"`
	Name                   string     `json:"name"`
	CreatedAt              time.Time  `json:"createdAt"`
	Level                  int        `json:"level"`
	ProfilePicture         *[]byte    `json:"profilePicture,omitempty"`
	WorkoutStartTime       *time.Time `json:"workoutStartTime,omitempty"`
	AverageWorkoutDuration *float64   `json:"averageWorkoutDuration,omitempty"`
}
