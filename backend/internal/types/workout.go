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
	IsActive      bool       `json:"isActive"`
	IsArchived    bool       `json:"isArchived"`
	IsStared      bool       `json:"isStared"`
	IsPinned      bool       `json:"isPinned"`
}

type WorkoutOverview struct {
	Workout   Workout `json:"workout"`
	PlanName  *string `json:"planName"`
	SplitName *string `json:"splitName"`
	PBCount   int     `json:"pbCount"`
}

type WorkoutDetails struct {
	WorkoutID int         `json:"workoutID"`
	Date      time.Time   `json:"date"`
	Gym       *Gym        `json:"gym"`
	Duration  *int        `json:"duration"`
	Split     *Split      `json:"split"`
	Exercises *[]Exercise `json:"exercises"`
	Sets      *[][]Set    `json:"sets"`
	PBSetIDs  *[]int      `json:"pbSetIDs"`
}

type PostWorkout struct {
	UserAccountID int       `json:"userAccountID"`
	GymID         *int      `json:"gymID"`
	SplitID       *int      `json:"splitID"`
	Starttime     time.Time `json:"starttime"`
	IsActive      bool      `json:"isActive"`
}

type StartWorkout struct {
	WorkoutID int  `json:"workoutID"`
	SplitID   *int `json:"splitID"`
	GymID     *int `json:"gymID"`
}

type FinishWorkout struct {
	SplitID   *int                     `json:"splitID"`
	GymID     *int                     `json:"gymID"`
	Exercises []NewExerciseInformation `json:"exercises"`
}
