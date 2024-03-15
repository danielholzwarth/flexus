package types

type UserList struct {
	ID       int `json:"id"`
	ListID   int `json:"listID"`
	MemberID int `json:"memberID"`
}

type EntireUserList struct {
	ID        int   `json:"id"`
	ListID    int   `json:"listID"`
	MemberIDs []int `json:"memberIDs"`
}
