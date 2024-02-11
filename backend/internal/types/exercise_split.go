package types

type ExerciseSplitID uint

type ExerciseSplit struct {
	ID         ExerciseSplitID `json:"id"`
	SplitID    *SplitID        `json:"splitID"`
	ExerciseID *ExerciseID     `json:"exerciseID"`
}
