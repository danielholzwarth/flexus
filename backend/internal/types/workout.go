package types

import "time"

type Workout struct {
	ID            int        `json:"id"`
	UserAccountID int        `json:"userAccountID"`
	PlanID        *int       `json:"planID"`
	SplitID       *int       `json:"splitID"`
	CreatedAt     time.Time  `json:"createdAt"`
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

type WorkoutDetails struct {
	WorkoutID    int         `json:"workoutID"`
	Date         time.Time   `json:"date"`
	Gym          *Gym        `json:"gym"`
	Duration     *int        `json:"duration"`
	Split        *Split      `json:"split"`
	Exercises    *[]Exercise `json:"exercises"`
	Measurements *[][]string `json:"measurements"`
}

type PostWorkout struct {
	UserAccountID int       `json:"userAccountID"`
	GymID         *int      `json:"gymID"`
	SplitID       *int      `json:"splitID"`
	Starttime     time.Time `json:"starttime"`
}
