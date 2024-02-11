package types

type ExerciseID uint

type Exercise struct {
	ID             ExerciseID      `json:"id"`
	CreatorID      *UserAccountID  `json:"creatorID"`
	Name           string          `json:"name"`
	ExerciseTypeID *ExerciseTypeID `json:"exerciseTypeID"`
}
