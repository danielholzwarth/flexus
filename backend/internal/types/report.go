package types

type ReportID uint

type Report struct {
	ID                        ReportID      `json:"id"`
	ReporterID                UserAccountID `json:"reporterID"`
	ReportedID                UserAccountID `json:"reportedID"`
	IsOffensiveProfilePicture bool          `json:"isOffensiveProfilePicture"`
	IsOffensiveName           bool          `json:"isOffensiveName"`
	IsOffensiveUsername       bool          `json:"isOffensiveUsername"`
	IsOther                   bool          `json:"isOther"`
	Message                   *string       `json:"message"`
}
