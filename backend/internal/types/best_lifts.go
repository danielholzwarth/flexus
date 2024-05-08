package types

type BestLift struct {
	ID            int  `json:"id"`
	UserAccountID *int `json:"userAccountID"`
	SetID         *int `json:"setID"`
	Position      int  `json:"positionID"`
}

type BestLiftOverview struct {
	ExerciseName string  `json:"exerciseName"`
	Repetitions  int     `json:"repetitions"`
	Workload     float64 `json:"workload"`
	IsRepetition bool    `json:"isRepetition"`
}
