package types

type UserAccountGym struct {
	ID            int  `json:"id"`
	UserAccountID *int `json:"userAccountID"`
	GymID         int  `json:"gymID"`
}
