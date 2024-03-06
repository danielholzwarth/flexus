package types

type Split struct {
	ID          int    `json:"id"`
	PlanID      *int   `json:"planID"`
	Name        string `json:"name"`
	OrderInPlan bool   `json:"orderInPlan"`
}
