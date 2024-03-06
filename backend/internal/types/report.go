package types

type Report struct {
	ID                        int     `json:"id"`
	ReporterID                int     `json:"reporterID"`
	ReportedID                int     `json:"reportedID"`
	IsOffensiveProfilePicture bool    `json:"isOffensiveProfilePicture"`
	IsOffensiveName           bool    `json:"isOffensiveName"`
	IsOffensiveUsername       bool    `json:"isOffensiveUsername"`
	IsOther                   bool    `json:"isOther"`
	Message                   *string `json:"message"`
}
