package types

type GenderID uint

type Gender struct {
	ID   GenderID `json:"id"`
	Name string   `json:"name"`
}
