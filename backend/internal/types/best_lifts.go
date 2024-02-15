package types

type BestLiftsID uint

type BestLifts struct {
	ID            BestLiftsID    `json:"id"`
	UserAccountID *UserAccountID `json:"userAccountID"`
	SetID         *SetID         `json:"setID"`
	PositionID    *PositionID    `json:"positionID"`
}
