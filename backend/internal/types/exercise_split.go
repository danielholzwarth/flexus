package types

type ExerciseSplit struct {
	ID         int  `json:"id"`
	SplitID    *int `json:"splitID"`
	ExerciseID *int `json:"exerciseID"`
}
