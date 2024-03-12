package postgres

import (
	"flexus/internal/types"
)

func (db *DB) CreateReport(report types.Report) error {
	query := `
        INSERT INTO report (reporter_id, reported_id, is_offensive_profile_picture, is_offensive_name, is_offensive_username, is_other, message)
        VALUES ($1, $2, $3, $4, $5, $6, $7);
	`

	_, err := db.pool.Exec(query,
		report.ReporterID,
		report.ReportedID,
		report.IsOffensiveProfilePicture,
		report.IsOffensiveName,
		report.IsOffensiveUsername,
		report.IsOther,
		report.Message,
	)

	if err != nil {
		return err
	}

	return nil
}
