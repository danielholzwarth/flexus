package types

type UserList struct {
	ID        int  `json:"id"`
	ListID    int  `json:"listID"`
	CreatorID *int `json:"creatorID"`
	MemberID  *int `json:"memberID"`
}
