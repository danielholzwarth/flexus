package types

type SetID uint

type Set struct {
	ID          SetID       `json:"id"`
	WorkoutID   *WorkoutID  `json:"workoutID"`
	ExerciseID  *ExerciseID `json:"exerciseID"`
	OrderNumber int         `json:"orderNumber"`
	Measurement string      `json:"measurement"`
}
