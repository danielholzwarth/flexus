package types

type LanguageID uint

type Gender struct {
	ID   GenderID `json:"id"`
	Name string   `json:"name"`
}
