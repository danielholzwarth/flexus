package types

type BestLift struct {
	ID            int  `json:"id"`
	UserAccountID *int `json:"userAccountID"`
	SetID         *int `json:"setID"`
	PositionID    *int `json:"positionID"`
}

type BestLiftOverview struct {
	ExerciseName string      `json:"exerciseName"`
	Measurement  Measurement `json:"measurement"`
}
