package types

type UserAccountGym struct {
	ID            int  `json:"id"`
	UserAccountID *int `json:"userAccountID,omitempty"`
	GymID         int  `json:"gymID"`
}
