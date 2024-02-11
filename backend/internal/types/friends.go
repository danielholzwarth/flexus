package types

type FriendsID uint

type Friends struct {
	ID          FriendsID      `json:"id"`
	RequesterID *UserAccountID `json:"requesterID"`
	RequestedID *UserAccountID `json:"requestedID"`
	IsAccepted  bool           `json:"isAccepted"`
}
