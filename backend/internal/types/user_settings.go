package types

type UserSettingsID uint

type UserSettings struct {
	ID                 UserSettingsID `json:"id"`
	UserID             *UserAccountID `json:"userAccountID"`
	Fontsize           int            `json:"fontsize"`
	IsDarkmode         bool           `json:"isDarkmode"`
	LanguageID         *LanguageID    `json:"languageID"`
	IsUnlisted         bool           `json:"isUnlisted"`
	IsPullFromEveryone bool           `json:"isPullFromEveryone"`
	PullUserListID     *UserListID    `json:"pullUserListID"`
	IsNotifyEveryone   bool           `json:"isNotifyEveryone"`
	NotifyUserListID   *UserListID    `json:"notifyUserListID"`
}
