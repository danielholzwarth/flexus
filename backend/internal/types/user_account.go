package types

import "time"

type UserAccountID uint

type UserAccount struct {
	ID        UserAccountID `json:"id"`
	CreatedAt time.Time     `json:"createdAt"`
	Name      string        `json:"name"`
}
