package types

type SplitID uint

type Split struct {
	ID          SplitID `json:"id"`
	PlanID      *PlanID `json:"planID"`
	Name        string  `json:"name"`
	OrderInPlan bool    `json:"orderInPlan"`
}
