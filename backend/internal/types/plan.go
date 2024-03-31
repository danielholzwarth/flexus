package types

import "time"

type Plan struct {
	ID                 int       `json:"id"`
	UserAccountID      int       `json:"userAccountID"`
	SplitCount         int       `json:"splitCount"`
	Name               string    `json:"name"`
	StartDate          time.Time `json:"startdate"`
	IsWeekly           bool      `json:"isWeekly"`
	IsMondayBlocked    bool      `json:"isMondayBlocked"`
	IsTuesdayBlocked   bool      `json:"isTuesdayBlocked"`
	IsWednesdayBlocked bool      `json:"isWednesdayBlocked"`
	IsThursdayBlocked  bool      `json:"isThursdayBlocked"`
	IsFridayBlocked    bool      `json:"isFridayBlocked"`
	IsSaturdayBlocked  bool      `json:"isSaturdayBlocked"`
	IsSundayBlocked    bool      `json:"isSundayBlocked"`
}

type CreatePlan struct {
	UserAccountID int    `json:"userAccountID"`
	SplitCount    int    `json:"splitCount"`
	Name          string `json:"name"`
	IsWeekly      bool   `json:"isWeekly"`
	RestList      []bool `json:"restList"`
}
