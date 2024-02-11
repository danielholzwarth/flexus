package types

type BestLiftsID uint

type BestLifts struct {
	ID         BestLiftsID    `json:"id"`
	UserID     *UserAccountID `json:"userID"`
	SetID      *SetID         `json:"setID"`
	PositionID *PositionID    `json:"positionID"`
}
