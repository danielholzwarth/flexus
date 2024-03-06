package types

type BestLift struct {
	ID            int  `json:"id"`
	UserAccountID *int `json:"userAccountID"`
	SetID         *int `json:"setID"`
	PositionID    *int `json:"positionID"`
}

type BestLiftOverview struct {
	ExerciseName string   `json:"exerciseName"`
	Repetitions  *int     `json:"repetitions"`
	Weight       *float64 `json:"weight"`
	Duration     *float64 `json:"duration"`
}
