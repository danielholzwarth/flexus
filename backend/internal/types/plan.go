package types

import "time"

type PlanID uint

type Plan struct {
	ID                 PlanID         `json:"id"`
	UserID             *UserAccountID `json:"userID"`
	PartCount          int            `json:"partCount"`
	Name               string         `json:"name"`
	Startdate          time.Time      `json:"startdate"`
	IsWeekly           bool           `json:"isWeekly"`
	IsMondayBlocked    bool           `json:"isMondayBlocked"`
	IsTuesdayBlocked   bool           `json:"isTuesdayBlocked"`
	IsWednesdayBlocked bool           `json:"isWednesdayBlocked"`
	IsThursdayBlocked  bool           `json:"isThursdayBlocked"`
	IsFridayBlocked    bool           `json:"isFridayBlocked"`
	IsSaturdayBlocked  bool           `json:"isSaturdayBlocked"`
	IsSundayBlocked    bool           `json:"isSundayBlocked"`
}
