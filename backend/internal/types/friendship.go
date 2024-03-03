package types

type FriendshipID uint

type Friendship struct {
	ID          FriendshipID  `json:"id"`
	RequestorID UserAccountID `json:"requestorID"`
	RequestedID UserAccountID `json:"requestedID"`
	IsAccepted  bool          `json:"isAccepted"`
}
