package types

type UserSettings struct {
	ID                 int     `json:"id"`
	UserAccountID      *int    `json:"userAccountID,omitempty"`
	FontSize           float64 `json:"fontSize"`
	IsDarkMode         bool    `json:"isDarkMode"`
	LanguageID         *int    `json:"languageID,omitempty"`
	IsUnlisted         bool    `json:"isUnlisted"`
	IsPullFromEveryone bool    `json:"isPullFromEveryone"`
	PullUserListID     *int    `json:"pullUserListID,omitempty"`
	IsNotifyEveryone   bool    `json:"isNotifyEveryone"`
	NotifyUserListID   *int    `json:"notifyUserListID,omitempty"`
	IsQuickAccess      bool    `json:"isQuickAccess"`
}
