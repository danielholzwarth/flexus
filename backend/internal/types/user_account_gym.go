package types

type UserAccountGymID uint

type UserAccountGym struct {
	ID     UserAccountGymID `json:"id"`
	UserID *UserAccountID   `json:"userID"`
	GymID  *GymID           `json:"gymID"`
}
