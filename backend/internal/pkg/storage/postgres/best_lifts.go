package postgres

import (
	"flexus/internal/types"
)

func (db *DB) GetBestLifts(userAccountID int) ([]types.BestLiftOverview, error) {
	var bestLiftOverviews []types.BestLiftOverview
	var typeID int
	query := `
        SELECT e.name AS "exerciseName", e.type_id, s.repetitions, s.workload
        FROM best_lifts bl
        JOIN set s ON bl.set_id = s.id
        JOIN exercise e ON s.exercise_id= e.id
		WHERE bl.user_id = $1
		ORDER BY bl.position_id
		LIMIT 3;
	`

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return []types.BestLiftOverview{}, err
	}
	defer rows.Close()

	for rows.Next() {
		var bestLiftOverview types.BestLiftOverview
		if err := rows.Scan(&bestLiftOverview.ExerciseName, &typeID, &bestLiftOverview.Repetitions, &bestLiftOverview.Workload); err != nil {
			return []types.BestLiftOverview{}, err
		}

		bestLiftOverview.IsRepetition = typeID == 1

		bestLiftOverviews = append(bestLiftOverviews, bestLiftOverview)
	}
	if err := rows.Err(); err != nil {
		return []types.BestLiftOverview{}, err
	}

	return bestLiftOverviews, nil
}
