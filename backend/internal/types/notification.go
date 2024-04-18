package types

type NotificationNewUserWorkingOut struct {
	Username  string `json:"username"`
	GymName   string `json:"gymName"`
	StartTime string `json:"startTime"`
}
