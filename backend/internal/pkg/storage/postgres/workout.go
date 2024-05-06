package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
	"strconv"
	"strings"
)

func (db DB) PostWorkout(postWorkout types.PostWorkout) error {
	tx, err := db.pool.Begin()
	if err != nil {
		return err
	}
	defer func() {
		if p := recover(); p != nil || err != nil {
			tx.Rollback()
			if p != nil {
				panic(p)
			}
		}
	}()

	query := `
		SELECT id 
		FROM workout 
		WHERE user_id = $1 AND gym_id = $2 AND endtime IS NULL;
	`

	var existingWorkoutID int
	err = tx.QueryRow(query, postWorkout.UserAccountID, postWorkout.GymID).Scan(&existingWorkoutID)
	if err != nil && err != sql.ErrNoRows {
		return err
	}

	if existingWorkoutID != 0 {
		_, err := tx.Exec("DELETE FROM workout WHERE id = $1", existingWorkoutID)
		if err != nil {
			return err
		}
	}

	query = `
		INSERT INTO workout (user_id, split_id, gym_id, created_at, starttime, is_active, is_archived, is_stared, is_pinned)
		VALUES ($1, $2, $3, NOW(), $4, $5, FALSE, FALSE, FALSE);
	`

	_, err = tx.Exec(
		query,
		postWorkout.UserAccountID,
		postWorkout.SplitID,
		postWorkout.GymID,
		postWorkout.Starttime,
		postWorkout.IsActive)
	if err != nil {
		return err
	}

	if err := tx.Commit(); err != nil {
		return err
	}

	return nil
}

func (db DB) GetWorkoutOverviews(userAccountID int) ([]types.WorkoutOverview, error) {
	var workoutOverviews []types.WorkoutOverview
	var pbCount int

	query := `
		SELECT w.id, w.user_id, w.split_id, w.created_at, w.starttime, w.endtime, w.is_active, w.is_archived, w.is_stared, w.is_pinned, p.name as plan_name, s.name as split_name
		FROM workout w
		LEFT JOIN split s ON w.split_id = s.id
		LEFT JOIN plan p ON s.plan_id = p.id
		WHERE w.user_id = $1
		ORDER BY w.is_active DESC, w.endtime IS NOT NULL, w.is_pinned DESC, w.starttime DESC;
    `

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return []types.WorkoutOverview{}, err
	}

	pbCountQuery := `
		SELECT COUNT(s.exercise_id)
		FROM set s
		JOIN workout w ON w.id = s.workout_id
		WHERE w.user_id = $1
		AND w.id = $2
		AND s.workload = (
			SELECT MAX(workload)
			FROM set
				JOIN workout w ON w.id = set.workout_id
			WHERE s.exercise_id = set.exercise_id
				AND w.user_id = $1
		);
	`

	for rows.Next() {
		var workoutOverview types.WorkoutOverview
		var workout types.Workout

		err := rows.Scan(
			&workout.ID,
			&workout.UserAccountID,
			&workout.SplitID,
			&workout.CreatedAt,
			&workout.Starttime,
			&workout.Endtime,
			&workout.IsActive,
			&workout.IsArchived,
			&workout.IsStared,
			&workout.IsPinned,
			&workoutOverview.PlanName,
			&workoutOverview.SplitName,
		)
		if err != nil {
			return nil, err
		}

		err = db.pool.QueryRow(pbCountQuery, userAccountID, workout.ID).Scan(&pbCount)
		if err != nil {
			if !errors.Is(err, sql.ErrNoRows) {
				return nil, err
			}
		}

		workoutOverview.Workout = workout
		workoutOverview.PBCount = pbCount
		workoutOverviews = append(workoutOverviews, workoutOverview)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return workoutOverviews, nil
}

func (db DB) GetWorkoutDetailsFromWorkoutID(userAccountID int, workoutID int) (types.WorkoutDetails, error) {
	var workoutDetails types.WorkoutDetails

	workoutDetails.WorkoutID = workoutID

	query := `
		SELECT w.starttime, w.endtime, w.gym_id, w.split_id
		FROM workout w
		JOIN user_account ua ON w.user_id = ua.id
		WHERE w.id = $1
		AND ua.id = $2;
	`

	var gymID *float64
	var splitID *float64

	err := db.pool.QueryRow(query, workoutID, userAccountID).Scan(
		&workoutDetails.Starttime,
		&workoutDetails.Endtime,
		&gymID,
		&splitID)
	if err != nil {
		return types.WorkoutDetails{}, err
	}

	if gymID != nil {
		var gym types.Gym
		query = `
			SELECT gym.*
			FROM gym
			JOIN workout w ON w.gym_id = gym.id
			WHERE w.id = $1
			AND w.user_id = $2
			AND gym.id = $3;
		`

		err := db.pool.QueryRow(query, workoutID, userAccountID, gymID).Scan(
			&gym.ID,
			&gym.Name,
			&gym.StreetName,
			&gym.HouseNumber,
			&gym.ZipCode,
			&gym.CityName,
			&gym.Latitude,
			&gym.Longitude)
		if err != nil {
			if !errors.Is(err, sql.ErrNoRows) {
				return types.WorkoutDetails{}, err
			}
		} else {
			workoutDetails.Gym = &gym
		}
	}

	//Get Split
	var split types.Split

	if splitID != nil {
		query = `
			SELECT *
			FROM split
			WHERE split.id = $1;
		`

		err = db.pool.QueryRow(query, splitID).Scan(
			&split.ID,
			&split.PlanID,
			&split.Name,
			&split.OrderInPlan,
		)
		if err != nil {
			return types.WorkoutDetails{}, err
		}

		workoutDetails.Split = &split
	}

	//Get Exercises
	var exercises []types.Exercise

	exerciseQuery := `
		SELECT DISTINCT exercise.*
		FROM exercise
		JOIN set s ON s.exercise_id = exercise.id
		WHERE s.workout_id = $1;
	`

	exerciseRows, err := db.pool.Query(exerciseQuery, workoutID)
	if err != nil {
		if !errors.Is(err, sql.ErrNoRows) {
			return types.WorkoutDetails{}, err
		}
	}
	defer exerciseRows.Close()

	for exerciseRows.Next() {
		var exercise types.Exercise
		err := exerciseRows.Scan(
			&exercise.ID,
			&exercise.CreatorID,
			&exercise.Name,
			&exercise.TypeID)
		if err != nil {
			return types.WorkoutDetails{}, err
		}

		exercises = append(exercises, exercise)
	}

	if err := exerciseRows.Err(); err != nil {
		return types.WorkoutDetails{}, err
	}

	workoutDetails.Exercises = &exercises

	//Get Measurements & Best Lifts
	var sets [][]types.Set
	var pbSetIDs []int

	measurementQuery := `
		SELECT set.*
		FROM set
		JOIN workout w ON set.workout_id = w.id
		WHERE w.user_id = $1
		AND set.exercise_id = $2
		AND w.id = $3;
	`

	pbQuery := `
		SELECT s.id
		FROM set s
		JOIN workout w ON w.id = s.workout_id
		WHERE w.user_id = $2
		AND s.exercise_id = $3
		AND w.id = $4
		AND $1 = (
			SELECT MAX(s.workload)
			FROM set s
			JOIN workout w ON w.id = s.workout_id
			WHERE w.user_id = $2
			AND s.exercise_id = $3
		)
		ORDER BY s.workload DESC;
	`

	for i := 0; i < len(exercises); i++ {
		measurementRows, err := db.pool.Query(measurementQuery, userAccountID, exercises[i].ID, workoutID)
		if err != nil {
			return types.WorkoutDetails{}, err
		}
		defer measurementRows.Close()

		var exerciseSets []types.Set
		for measurementRows.Next() {
			var set types.Set
			err := measurementRows.Scan(&set.ID, &set.WorkoutID, &set.ExerciseID, &set.OrderNumber, &set.Repetitions, &set.Workload)
			if err != nil {
				return types.WorkoutDetails{}, err
			}

			var pbSetID int

			err = db.pool.QueryRow(pbQuery, set.Workload, userAccountID, exercises[i].ID, workoutID).Scan(&pbSetID)
			if err != nil {
				if !errors.Is(err, sql.ErrNoRows) {
					return types.WorkoutDetails{}, err
				}
			}

			if pbSetID != 0 {
				pbSetIDs = append(pbSetIDs, pbSetID)
			}

			exerciseSets = append(exerciseSets, set)
		}

		if err := measurementRows.Err(); err != nil {
			return types.WorkoutDetails{}, err
		}

		sets = append(sets, exerciseSets)
	}

	workoutDetails.Sets = &sets
	workoutDetails.PBSetIDs = &pbSetIDs

	return workoutDetails, nil
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

func (db DB) PatchStartWorkout(userAccountID int, workout types.StartWorkout) error {
	tx, err := db.pool.Begin()
	if err != nil {
		return err
	}
	defer func() {
		if p := recover(); p != nil || err != nil {
			tx.Rollback()
			if p != nil {
				panic(p)
			}
		}
	}()

	query := `
		SELECT EXISTS(
			SELECT 1
			FROM workout
			WHERE user_id = $1 
			AND is_active = TRUE
		);
	`

	var exists bool
	err = tx.QueryRow("SELECT EXISTS(SELECT 1 FROM workout WHERE user_id = $1 AND is_active = TRUE)", userAccountID).Scan(&exists)
	if err != nil {
		return err
	}
	if exists {
		return errors.New("there is already an active workout")
	}

	query = `
		UPDATE workout
		SET split_id = $3, gym_id = $4, starttime = NOW(), is_active = TRUE
		WHERE id = $1 
		AND user_id = $2;
	`

	_, err = tx.Exec(query, workout.WorkoutID, userAccountID, workout.SplitID, workout.GymID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("workout not found")
		}
		return err
	}

	if err := tx.Commit(); err != nil {
		return err
	}

	return nil
}

func (db DB) PatchFinishWorkout(userAccountID int, workout types.FinishWorkout) error {
	tx, err := db.pool.Begin()
	if err != nil {
		return err
	}
	defer func() {
		if p := recover(); p != nil || err != nil {
			tx.Rollback()
			if p != nil {
				panic(p)
			}
		}
	}()

	//Patch Workout
	var workoutID int

	query := `
		UPDATE workout
		SET endtime = NOW(), is_active = FALSE
		WHERE user_id = $1 
		AND is_active = TRUE
		RETURNING id;
	`

	err = tx.QueryRow(query, userAccountID).Scan(&workoutID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("workout not found")
		}
		return err
	}

	//Create Sets
	query = `
		INSERT INTO set (workout_id, exercise_id, order_number, repetitions, workload)
		VALUES ($1, $2, $3, $4, $5);
	`

	for exIndex := 0; exIndex < len(workout.Exercises); exIndex++ {
		for measIndex := 0; measIndex < len(workout.Exercises[exIndex].Measurements); measIndex++ {
			_, err = tx.Exec(
				query,
				workoutID,
				workout.Exercises[exIndex].Exercise.ID,
				exIndex*len(workout.Exercises)+measIndex+1,
				workout.Exercises[exIndex].Measurements[measIndex].Repetitions,
				workout.Exercises[exIndex].Measurements[measIndex].Workload)
			if err != nil {
				return err
			}
		}
	}

	if err := tx.Commit(); err != nil {
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
		INTO workout user_id, created_at, starttime, endtime, is_archived, is_stared, is_pinned
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
				workout.CreatedAt,
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
