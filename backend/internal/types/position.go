package types

type PositionID uint

type Position struct {
	ID   PositionID `json:"id"`
	Name string     `json:"name"`
}
