package types

type UserListID uint

type UserList struct {
	ID        UserListID     `json:"id"`
	ListID    int            `json:"listID"`
	CreatorID *UserAccountID `json:"creatorID"`
	MemberID  *UserAccountID `json:"memberID"`
}
