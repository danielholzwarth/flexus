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
}

type WorkoutOverview struct {
	Workout   Workout `json:"workout"`
	PlanName  *string `json:"planName"`
	SplitName *string `json:"splitName"`
}
