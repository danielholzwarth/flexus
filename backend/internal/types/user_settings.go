package types

type UserSettingsID uint

type UserSettings struct {
	ID                 UserSettingsID `json:"id"`
	UserAccountID      *UserAccountID `json:"userAccountID"`
	FontSize           float64        `json:"fontSize"`
	IsDarkMode         bool           `json:"isDarkMode"`
	LanguageID         *LanguageID    `json:"languageID"`
	IsUnlisted         bool           `json:"isUnlisted"`
	IsPullFromEveryone bool           `json:"isPullFromEveryone"`
	PullUserListID     *UserListID    `json:"pullUserListID"`
	IsNotifyEveryone   bool           `json:"isNotifyEveryone"`
	NotifyUserListID   *UserListID    `json:"notifyUserListID"`
}
