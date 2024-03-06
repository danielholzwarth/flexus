package types

type Friendship struct {
	ID          int  `json:"id"`
	RequestorID int  `json:"requestorID"`
	RequestedID int  `json:"requestedID"`
	IsAccepted  bool `json:"isAccepted"`
}
