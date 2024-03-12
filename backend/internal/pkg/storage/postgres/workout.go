package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
)

func (db DB) GetWorkoutOverviews(userAccountID int) ([]types.WorkoutOverview, error) {
	query := `
		SELECT w.id, w.user_id, w.split_id, w.starttime, w.endtime, w.is_archived, p.name as plan_name, s.name as split_name
		FROM workout w
		LEFT JOIN split s ON w.split_id = s.id
		LEFT JOIN plan p ON s.plan_id = p.id
		WHERE w.user_id = $1
		ORDER BY w.starttime DESC;
    `

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return []types.WorkoutOverview{}, err
	}

	var workoutOverviews []types.WorkoutOverview

	for rows.Next() {
		var workoutOverview types.WorkoutOverview
		var workout types.Workout

		err := rows.Scan(
			&workout.ID,
			&workout.UserAccountID,
			&workout.SplitID,
			&workout.Starttime,
			&workout.Endtime,
			&workout.IsArchived,
			&workoutOverview.PlanName,
			&workoutOverview.SplitName,
		)
		if err != nil {
			return nil, err
		}

		workoutOverview.Workout = workout
		workoutOverviews = append(workoutOverviews, workoutOverview)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return workoutOverviews, nil
}

func (db DB) PatchWorkout(userAccountID int, workoutID int, columnName string, value any) error {
	var query string
	var args []interface{}

	if value == nil {
		query = `
			UPDATE workout
			SET ` + columnName + ` = NULL
			WHERE id = $1 AND user_id = $2;
		`
		args = []interface{}{workoutID, userAccountID}
	} else {
		query = `
			UPDATE workout
			SET ` + columnName + ` = $1
			WHERE id = $2 AND user_id = $3;
		`
		args = []interface{}{value, workoutID, userAccountID}
	}

	_, err := db.pool.Exec(query, args...)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("workout not found")
		}
		return err
	}

	return nil
}

func (db DB) DeleteWorkout(userAccountID int, workoutID int) error {
	query := `
		DELETE 
		FROM workout 
		WHERE id = $1;
	`
	_, err := db.pool.Exec(query, workoutID)
	if err != nil {
		return err
	}

	return nil
}
