package types

type UserSettingsID uint

type UserSettings struct {
	ID                 UserSettingsID `json:"id"`
	UserID             *UserAccountID `json:"userAccountID"`
	FontSize           int            `json:"fontsize"`
	IsDarkMode         bool           `json:"isDarkmode"`
	LanguageID         *LanguageID    `json:"languageID"`
	IsUnlisted         bool           `json:"isUnlisted"`
	IsPullFromEveryone bool           `json:"isPullFromEveryone"`
	PullUserListID     *UserListID    `json:"pullUserListID"`
	IsNotifyEveryone   bool           `json:"isNotifyEveryone"`
	NotifyUserListID   *UserListID    `json:"notifyUserListID"`
}
