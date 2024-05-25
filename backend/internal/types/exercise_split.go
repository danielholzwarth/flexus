package types

type ExerciseSplit struct {
	ID         int  `json:"id"`
	SplitID    *int `json:"splitID,omitempty"`
	ExerciseID *int `json:"exerciseID,omitempty"`
}
