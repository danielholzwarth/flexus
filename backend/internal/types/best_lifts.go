package types

type BestLiftID uint

type BestLift struct {
	ID            BestLiftID     `json:"id"`
	UserAccountID *UserAccountID `json:"userAccountID"`
	SetID         *SetID         `json:"setID"`
	PositionID    *PositionID    `json:"positionID"`
}

type BestLiftOverview struct {
	ExerciseName string     `json:"exerciseName"`
	Repetitions  *int       `json:"repetitions"`
	Weight       *float64   `json:"weight"`
	Duration     *float64   `json:"duration"`
}
