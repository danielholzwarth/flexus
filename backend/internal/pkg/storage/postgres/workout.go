package postgres

import (
	"flexus/internal/types"
)

func (db DB) GetWorkouts(userAccountID types.UserAccountID) ([]types.Workout, error) {
	query := `
        SELECT *
        FROM workout
        WHERE user_id = $1 AND is_archived = false;
    `

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return []types.Workout{}, err
	}

	var workouts []types.Workout

	for rows.Next() {
		var workout types.Workout
		var planID *types.PlanID
		var splitID *types.SplitID

		err := rows.Scan(
			&workout.ID,
			&workout.UserAccountID,
			&planID,
			&splitID,
			&workout.Starttime,
			&workout.Endtime,
			&workout.IsArchived,
		)
		if err != nil {
			return nil, err
		}

		if planID == nil {
			planID = new(types.PlanID)
		}
		workout.PlanID = planID

		if splitID == nil {
			splitID = new(types.SplitID)
		}
		workout.SplitID = splitID

		workouts = append(workouts, workout)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return workouts, nil
}

func (db DB) GetSearchedWorkouts(userAccountID types.UserAccountID, keyword string) ([]types.Workout, error) {
	query := `
        SELECT w.*
        FROM workout w
        JOIN plan p ON w.plan_id = p.id
        WHERE w.user_id = $1 AND w.is_archived = false AND p.name LIKE '%' || $2 || '%';
    `

	rows, err := db.pool.Query(query, userAccountID, keyword)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var workouts []types.Workout

	for rows.Next() {
		var workout types.Workout
		err := rows.Scan(
			&workout.ID,
			&workout.UserAccountID,
			&workout.PlanID,
			&workout.SplitID,
			&workout.Starttime,
			&workout.Endtime,
			&workout.IsArchived,
		)
		if err != nil {
			return nil, err
		}
		workouts = append(workouts, workout)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return workouts, nil
}

func (db DB) GetArchivedWorkouts(userAccountID types.UserAccountID) ([]types.Workout, error) {
	query := `
        SELECT *
        FROM workout
        WHERE user_id = $1 AND is_archived = true;
    `

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var workouts []types.Workout

	for rows.Next() {
		var workout types.Workout
		err := rows.Scan(
			&workout.ID,
			&workout.UserAccountID,
			&workout.PlanID,
			&workout.SplitID,
			&workout.Starttime,
			&workout.Endtime,
			&workout.IsArchived,
		)
		if err != nil {
			return nil, err
		}
		workouts = append(workouts, workout)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return workouts, nil
}

func (db DB) GetSearchedArchivedWorkouts(userAccountID types.UserAccountID, keyword string) ([]types.Workout, error) {
	query := `
        SELECT w.*
        FROM workout w
        JOIN plan p ON w.plan_id = p.id
        WHERE w.user_id = $1 AND w.is_archived = true AND p.name LIKE '%' || $2 || '%';
    `

	rows, err := db.pool.Query(query, userAccountID, keyword)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var workouts []types.Workout

	for rows.Next() {
		var workout types.Workout
		err := rows.Scan(
			&workout.ID,
			&workout.UserAccountID,
			&workout.PlanID,
			&workout.SplitID,
			&workout.Starttime,
			&workout.Endtime,
			&workout.IsArchived,
		)
		if err != nil {
			return nil, err
		}
		workouts = append(workouts, workout)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return workouts, nil
}
