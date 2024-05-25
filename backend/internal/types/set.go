package types

type Set struct {
	ID          int     `json:"id"`
	WorkoutID   *int    `json:"workoutID,omitempty"`
	ExerciseID  int     `json:"exerciseID"`
	OrderNumber int     `json:"orderNumber"`
	Repetitions int     `json:"repetitions"`
	Workload    float64 `json:"workload"`
}
