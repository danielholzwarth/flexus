package postgres

import (
	"flexus/internal/types"
)

func (db DB) GetWorkoutOverviews(userAccountID types.UserAccountID) ([]types.WorkoutOverview, error) {
	query := `
		SELECT w.id, w.user_id, w.split_id, w.starttime, w.endtime, w.is_archived, p.name as plan_name, s.name as split_name
		FROM workout w
		LEFT JOIN split s ON w.split_id = s.id
		LEFT JOIN plan p ON s.plan_id = p.id
		WHERE w.user_id = $1 AND w.is_archived = false
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
		var splitID *types.SplitID

		err := rows.Scan(
			&workout.ID,
			&workout.UserAccountID,
			&splitID,
			&workout.Starttime,
			&workout.Endtime,
			&workout.IsArchived,
			&workoutOverview.PlanName,
			&workoutOverview.SplitName,
		)
		if err != nil {
			return nil, err
		}

		if splitID == nil {
			splitID = new(types.SplitID)
		}
		workout.SplitID = splitID
		workoutOverview.Workout = workout

		workoutOverviews = append(workoutOverviews, workoutOverview)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return workoutOverviews, nil
}

func (db DB) GetSearchedWorkoutOverviews(userAccountID types.UserAccountID, keyword string) ([]types.WorkoutOverview, error) {
	query := `
		SELECT w.id, w.user_id, w.split_id, w.starttime, w.endtime, w.is_archived, p.name as plan_name, s.name as split_name
		FROM workout w
		LEFT JOIN split s ON w.split_id = s.id
		LEFT JOIN plan p ON s.plan_id = p.id
		WHERE w.user_id = $1 AND w.is_archived = false
		AND (LOWER(p.name) LIKE '%' || LOWER($2) || '%' OR LOWER(s.name) LIKE '%' || LOWER($2) || '%')
		ORDER BY w.starttime DESC;
    `

	rows, err := db.pool.Query(query, userAccountID, keyword)
	if err != nil {
		return []types.WorkoutOverview{}, err
	}

	var workoutOverviews []types.WorkoutOverview

	for rows.Next() {
		var workoutOverview types.WorkoutOverview
		var workout types.Workout
		var splitID *types.SplitID

		err := rows.Scan(
			&workout.ID,
			&workout.UserAccountID,
			&splitID,
			&workout.Starttime,
			&workout.Endtime,
			&workout.IsArchived,
			&workoutOverview.PlanName,
			&workoutOverview.SplitName,
		)
		if err != nil {
			return nil, err
		}

		if splitID == nil {
			splitID = new(types.SplitID)
		}
		workout.SplitID = splitID
		workoutOverview.Workout = workout

		workoutOverviews = append(workoutOverviews, workoutOverview)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return workoutOverviews, nil
}

func (db DB) GetArchivedWorkoutOverviews(userAccountID types.UserAccountID) ([]types.WorkoutOverview, error) {
	query := `
		SELECT w.id, w.user_id, w.split_id, w.starttime, w.endtime, w.is_archived, p.name as plan_name, s.name as split_name
		FROM workout w
		LEFT JOIN split s ON w.split_id = s.id
		LEFT JOIN plan p ON s.plan_id = p.id
		WHERE w.user_id = $1 AND w.is_archived = true
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
		var splitID *types.SplitID

		err := rows.Scan(
			&workout.ID,
			&workout.UserAccountID,
			&splitID,
			&workout.Starttime,
			&workout.Endtime,
			&workout.IsArchived,
			&workoutOverview.PlanName,
			&workoutOverview.SplitName,
		)
		if err != nil {
			return nil, err
		}

		if splitID == nil {
			splitID = new(types.SplitID)
		}
		workout.SplitID = splitID
		workoutOverview.Workout = workout

		workoutOverviews = append(workoutOverviews, workoutOverview)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return workoutOverviews, nil
}

func (db DB) GetSearchedArchivedWorkoutOverviews(userAccountID types.UserAccountID, keyword string) ([]types.WorkoutOverview, error) {
	query := `
		SELECT w.id, w.user_id, w.split_id, w.starttime, w.endtime, w.is_archived, p.name as plan_name, s.name as split_name
		FROM workout w
		LEFT JOIN split s ON w.split_id = s.id
		LEFT JOIN plan p ON s.plan_id = p.id
		WHERE w.user_id = $1 AND w.is_archived = true
		AND (LOWER(p.name) LIKE '%' || LOWER($2) || '%' OR LOWER(s.name) LIKE '%' || LOWER($2) || '%')
		ORDER BY w.starttime DESC;
    `

	rows, err := db.pool.Query(query, userAccountID, keyword)
	if err != nil {
		return []types.WorkoutOverview{}, err
	}

	var workoutOverviews []types.WorkoutOverview

	for rows.Next() {
		var workoutOverview types.WorkoutOverview
		var workout types.Workout
		var splitID *types.SplitID

		err := rows.Scan(
			&workout.ID,
			&workout.UserAccountID,
			&splitID,
			&workout.Starttime,
			&workout.Endtime,
			&workout.IsArchived,
			&workoutOverview.PlanName,
			&workoutOverview.SplitName,
		)
		if err != nil {
			return nil, err
		}

		if splitID == nil {
			splitID = new(types.SplitID)
		}
		workout.SplitID = splitID
		workoutOverview.Workout = workout

		workoutOverviews = append(workoutOverviews, workoutOverview)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return workoutOverviews, nil
}
