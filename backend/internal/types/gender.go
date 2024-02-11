package types

type GenderID uint

type Language struct {
	ID   LanguageID `json:"id"`
	Name string     `json:"name"`
}
