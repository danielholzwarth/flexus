package types

type ExerciseTypeID uint

type ExerciseType struct {
	ID   ExerciseTypeID `json:"id"`
	Name string         `json:"name"`
}
