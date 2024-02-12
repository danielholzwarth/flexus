package types

type LanguageID uint

type Language struct {
	ID   LanguageID `json:"id"`
	Name string     `json:"name"`
}
