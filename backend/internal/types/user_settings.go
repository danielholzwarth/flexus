package types

type UserSettings struct {
	ID                 int     `json:"id"`
	UserAccountID      *int    `json:"userAccountID"`
	FontSize           float64 `json:"fontSize"`
	IsDarkMode         bool    `json:"isDarkMode"`
	LanguageID         *int    `json:"languageID"`
	IsUnlisted         bool    `json:"isUnlisted"`
	IsPullFromEveryone bool    `json:"isPullFromEveryone"`
	PullUserListID     *int    `json:"pullUserListID"`
	IsNotifyEveryone   bool    `json:"isNotifyEveryone"`
	NotifyUserListID   *int    `json:"notifyUserListID"`
}
