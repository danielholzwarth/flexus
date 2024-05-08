package postgres

import (
	"flexus/internal/types"
)

func (db *DB) PostBestLift(userAccountID int, exerciseID int, position int) ([]types.BestLiftOverview, error) {
	var setID int

	query := `
		SELECT set.id 
		FROM set 
		JOIN workout ON workout.id = set.workout_id
		WHERE set.exercise_id = $1
		AND workout.user_id = $2
		ORDER BY workload DESC
		LIMIT 1;
	`

	err := db.pool.QueryRow(query, exerciseID, userAccountID).Scan(&setID)
	if err != nil {
		return []types.BestLiftOverview{}, err
	}

	query = `
		INSERT INTO best_lifts (user_id, set_id, position)
		VALUES ($1, $2, $3);	
	`

	_, err = db.pool.Exec(query, userAccountID, setID, position)
	if err != nil {
		return []types.BestLiftOverview{}, err
	}

	bestLifts, err := db.GetBestLiftsFromUserID(userAccountID)
	if err != nil {
		return []types.BestLiftOverview{}, err
	}

	return bestLifts, nil
}

func (db *DB) PatchBestLift(userAccountID int, exerciseID int, position int) ([]types.BestLiftOverview, error) {
	var exists bool

	query := `
		SELECT 1
		FROM best_lifts
		WHERE user_id = $1
		AND position = $2;
	`

	err := db.pool.QueryRow(query, userAccountID, position).Scan(&exists)
	if err != nil {
		return []types.BestLiftOverview{}, err
	}

	if exists {
		var setID int

		query := `
			SELECT set.id 
			FROM set 
			JOIN workout ON workout.id = set.workout_id
			WHERE set.exercise_id = $1
			AND workout.user_id = $2
			ORDER BY workload DESC
			LIMIT 1;
		`

		err := db.pool.QueryRow(query, userAccountID, setID, position).Scan(&setID)
		if err != nil {
			return []types.BestLiftOverview{}, err
		}

		query = `
			UPDATE best_lifts
			SET set_id = $1
			WHERE user_id = $2 
			AND position = $3;
		`

		_, err = db.pool.Exec(query, setID, userAccountID, position)
		if err != nil {
			return []types.BestLiftOverview{}, err
		}

		bestLifts, err := db.GetBestLiftsFromUserID(userAccountID)
		if err != nil {
			return []types.BestLiftOverview{}, err
		}

		return bestLifts, nil
	} else {
		bestLifts, err := db.PostBestLift(userAccountID, exerciseID, position)
		if err != nil {
			return []types.BestLiftOverview{}, err
		}

		return bestLifts, nil
	}
}

func (db *DB) GetBestLiftsFromUserID(userAccountID int) ([]types.BestLiftOverview, error) {
	var bestLiftOverviews []types.BestLiftOverview
	var typeID int
	query := `
        SELECT e.name AS "exerciseName", e.type_id, s.repetitions, s.workload
        FROM best_lifts bl
        JOIN set s ON bl.set_id = s.id
        JOIN exercise e ON s.exercise_id= e.id
		WHERE bl.user_id = $1
		ORDER BY bl.position;
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
