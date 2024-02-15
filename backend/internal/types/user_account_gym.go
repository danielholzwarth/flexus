package types

type UserAccountGymID uint

type UserAccountGym struct {
	ID            UserAccountGymID `json:"id"`
	UserAccountID *UserAccountID   `json:"userAccountID"`
	GymID         *GymID           `json:"gymID"`
}
