package types

import (
	"time"
)

type Plan struct {
	ID              int       `json:"id"`
	UserAccountID   int       `json:"userAccountID"`
	SplitCount      int       `json:"splitCount"`
	Name            string    `json:"name"`
	CreatedAt       time.Time `json:"createdAt"`
	IsActive        bool      `json:"isActive"`
	IsWeekly        bool      `json:"isWeekly"`
	IsMondayRest    bool      `json:"isMondayRest"`
	IsTuesdayRest   bool      `json:"isTuesdayRest"`
	IsWednesdayRest bool      `json:"isWednesdayRest"`
	IsThursdayRest  bool      `json:"isThursdayRest"`
	IsFridayRest    bool      `json:"isFridayRest"`
	IsSaturdayRest  bool      `json:"isSaturdayRest"`
	IsSundayRest    bool      `json:"isSundayRest"`
}

type CreatePlan struct {
	UserAccountID int      `json:"userAccountID"`
	SplitCount    int      `json:"splitCount"`
	Name          string   `json:"name"`
	IsWeekly      bool     `json:"isWeekly"`
	RestList      []bool   `json:"restList"`
	Splits        []string `json:"splits"`
	ExerciseIDs   [][]int  `json:"exerciseIDs"`
}

type PlanOverview struct {
	Plan           Plan            `json:"plan"`
	SplitOverviews []SplitOverview `json:"splitOverviews"`
}
