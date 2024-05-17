package types

type Split struct {
	ID          int    `json:"id"`
	PlanID      *int   `json:"planID"`
	Name        string `json:"name"`
	OrderInPlan int    `json:"orderInPlan"`
}

type SplitOverview struct {
	Split        Split         `json:"split"`
	Exercises    []Exercise    `json:"exercises"`
	Measurements []Measurement `json:"measurements"`
}
