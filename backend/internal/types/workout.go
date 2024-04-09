package types

import "time"

type Workout struct {
	ID            int        `json:"id"`
	UserAccountID int        `json:"userAccountID"`
	PlanID        *int       `json:"planID"`
	SplitID       *int       `json:"splitID"`
	Starttime     time.Time  `json:"starttime"`
	Endtime       *time.Time `json:"endtime"`
	IsArchived    bool       `json:"isArchived"`
	IsStared      bool       `json:"isStared"`
	IsPinned      bool       `json:"isPinned"`
}

type WorkoutOverview struct {
	Workout   Workout `json:"workout"`
	PlanName  *string `json:"planName"`
	SplitName *string `json:"splitName"`
}

type PostWorkout struct {
	UserAccountID int       `json:"userAccountID"`
	PlanID        *int      `json:"planID"`
	SplitID       *int      `json:"splitID"`
	Starttime     time.Time `json:"starttime"`
}
