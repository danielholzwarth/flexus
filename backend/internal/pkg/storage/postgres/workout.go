package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
	"strconv"
	"strings"
)

func (db DB) GetWorkoutOverviews(userAccountID int) ([]types.WorkoutOverview, error) {
	query := `
		SELECT w.id, w.user_id, w.split_id, w.starttime, w.endtime, w.is_archived, w.is_stared, w.is_pinned, p.name as plan_name, s.name as split_name
		FROM workout w
		LEFT JOIN split s ON w.split_id = s.id
		LEFT JOIN plan p ON s.plan_id = p.id
		WHERE w.user_id = $1
		ORDER BY w.is_pinned DESC, w.starttime DESC;
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
			&workout.IsStared,
			&workout.IsPinned,
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

func (db DB) PatchEntireWorkouts(userAccountID int, workouts []types.Workout) error {
	tx, err := db.pool.Begin()
	if err != nil {
		return err
	}
	defer func() {
		if p := recover(); p != nil {
			tx.Rollback()
			panic(p)
		} else if err != nil {
			tx.Rollback()
		} else {
			err = tx.Commit()
		}
	}()

	//Delete all which got deleted
	var ids = getWorkoutIDs(workouts)

	deleteQuery := `
		DELETE FROM workout
		WHERE id NOT IN (` + strings.Join(ids, ",") + `) AND user_id = $1;
	`

	_, err = tx.Exec(deleteQuery, userAccountID)
	if err != nil {
		return err
	}

	//Update all which got updated
	updateQuery := `
		UPDATE workout
		SET starttime = $1, endtime = $2, is_archived = $3, is_stared = $4, is_pinned = $5 
		WHERE user_id = $6 AND id = $7;
	`

	//Insert all which got created
	insertQuery := `
		INSERT 
		INTO workout user_id, starttime, endtime, is_archived, is_stared, is_pinned
		VALUES ($1, $2, $3, $4, $5, $6);
	`

	for _, workout := range workouts {
		var exists bool

		query := `
			SELECT EXISTS(
				SELECT 1
				FROM workout
				WHERE user_id = $1 AND id = $2
			) ;

		`

		err = tx.QueryRow(query, userAccountID, workout.ID).Scan(&exists)
		if err != nil {
			return err
		}

		if exists {
			_, err = tx.Exec(
				updateQuery,
				workout.Starttime,
				workout.Endtime,
				workout.IsArchived,
				workout.IsStared,
				workout.IsPinned,
				userAccountID,
				workout.ID,
			)
			if err != nil {
				return err
			}
		} else {
			_, err = tx.Exec(
				insertQuery,
				userAccountID,
				workout.Starttime,
				workout.Endtime,
				workout.IsArchived,
				workout.IsStared,
				workout.IsPinned,
			)
			if err != nil {
				return err
			}
		}
	}

	return nil
}

func getWorkoutIDs(workouts []types.Workout) []string {
	ids := make([]string, 0, len(workouts))
	for _, workout := range workouts {
		ids = append(ids, strconv.Itoa(workout.ID))
	}
	return ids
}
