package types

import "time"

type WorkoutID uint

type Workout struct {
	ID            WorkoutID      `json:"id"`
	UserAccountID *UserAccountID `json:"userAccountID"`
	PlanID        *PlanID        `json:"planID"`
	SplitID       *SplitID       `json:"splitID"`
	Starttime     time.Time      `json:"starttime"`
	Endtime       time.Time      `json:"endtime"`
	IsArchived    bool           `json:"isArchived"`
}
