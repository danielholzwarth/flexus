package types

import "time"

type Workout struct {
	ID            int        `json:"id"`
	UserAccountID int        `json:"userAccountID"`
	PlanID        *int       `json:"planID,omitempty"`
	SplitID       *int       `json:"splitID,omitempty"`
	CreatedAt     time.Time  `json:"createdAt"`
	Starttime     time.Time  `json:"starttime"`
	Endtime       *time.Time `json:"endtime,omitempty"`
	IsActive      bool       `json:"isActive"`
	IsArchived    bool       `json:"isArchived"`
	IsStared      bool       `json:"isStared"`
	IsPinned      bool       `json:"isPinned"`
}

type WorkoutOverview struct {
	Workout   Workout `json:"workout"`
	PlanName  *string `json:"planName,omitempty"`
	SplitName *string `json:"splitName,omitempty"`
	PBCount   int     `json:"pbCount"`
}

type WorkoutDetails struct {
	WorkoutID int         `json:"workoutID"`
	Starttime time.Time   `json:"starttime"`
	Endtime   *time.Time  `json:"endtime,omitempty"`
	Gym       *Gym        `json:"gym,omitempty"`
	Split     *Split      `json:"split,omitempty"`
	Exercises *[]Exercise `json:"exercises,omitempty"`
	Sets      *[][]Set    `json:"sets,omitempty"`
	PBSetIDs  *[]int      `json:"pbSetIDs,omitempty"`
}

type PostWorkout struct {
	UserAccountID int       `json:"userAccountID"`
	GymID         *int      `json:"gymID,omitempty"`
	SplitID       *int      `json:"splitID,omitempty"`
	Starttime     time.Time `json:"starttime"`
	IsActive      bool      `json:"isActive"`
}

type StartWorkout struct {
	WorkoutID int  `json:"workoutID"`
	SplitID   *int `json:"splitID,omitempty"`
	GymID     *int `json:"gymID,omitempty"`
}

type FinishWorkout struct {
	SplitID   *int                     `json:"splitID,omitempty"`
	GymID     *int                     `json:"gymID,omitempty"`
	Exercises []NewExerciseInformation `json:"exercises"`
}
