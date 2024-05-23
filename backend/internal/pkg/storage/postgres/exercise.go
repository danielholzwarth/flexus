package postgres

import (
	"errors"
	"flexus/internal/types"
)

func (db *DB) PostExercise(userAccountID int, name string, typeID int) (types.Exercise, error) {
	query := `
		SELECT EXISTS(
			SELECT 1 
			FROM exercise
			WHERE (exercise.name = $1 AND exercise.creator_id IS NULL)
			OR (exercise.name = $1 AND exercise.creator_id = $2)
		);
	`

	var exists bool
	err := db.pool.QueryRow(query, name, typeID).Scan(&exists)
	if err != nil {
		return types.Exercise{}, err
	}

	if exists {
		return types.Exercise{}, errors.New("exercise exists already")
	}

	query = `
		INSERT INTO exercise (creator_id, name, type_id)
		VALUES ($1, $2, $3)
		RETURNING id;
	`

	var exercise types.Exercise
	exercise.CreatorID = &userAccountID
	exercise.TypeID = typeID
	exercise.Name = name

	err = db.pool.QueryRow(query, userAccountID, name, typeID).Scan(&exercise.ID)
	if err != nil {
		return types.Exercise{}, err
	}

	return exercise, nil
}

func (db *DB) GetExercises(userAccountID int) ([]types.Exercise, error) {
	var exercises []types.Exercise

	query := `
        SELECT id, creator_id, name, type_id
        FROM exercise
		WHERE creator_id IS NULL OR creator_id = $1
		ORDER BY name ASC;
    `

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var exercise types.Exercise

		err := rows.Scan(&exercise.ID, &exercise.CreatorID, &exercise.Name, &exercise.TypeID)
		if err != nil {
			return nil, err
		}

		exercises = append(exercises, exercise)
	}

	return exercises, nil
}

func (db *DB) GetExerciseFromExerciseID(userAccountID int, exerciseID int) (types.ExerciseInformation, error) {
	var information types.ExerciseInformation

	query := `
        SELECT *
        FROM exercise e
		WHERE e.id = $1;
    `

	err := db.pool.QueryRow(query, exerciseID).Scan(&information.ID, &information.CreatorID, &information.Name, &information.TypeID)
	if err != nil {
		return types.ExerciseInformation{}, err
	}

	oldMeasurementQuery := `
		SELECT s.repetitions, s.workload
		FROM set s
		JOIN workout w ON w.id = s.workout_id
		WHERE s.exercise_id = $1
		AND w.user_id = $2
		AND s.workout_id = (
			SELECT MAX(w.id)
			FROM workout w
			JOIN set s ON s.workout_id = w.id
			WHERE s.exercise_id = $1
			AND w.user_id = $2
		)
		ORDER BY s.order_number ASC;
	`

	var oldMeasurements []types.Measurement

	measurementRows, err := db.pool.Query(oldMeasurementQuery, information.ID, userAccountID)
	if err != nil {
		return types.ExerciseInformation{}, err
	}
	defer measurementRows.Close()

	for measurementRows.Next() {
		var oldMeasurement types.Measurement

		err := measurementRows.Scan(&oldMeasurement.Repetitions, &oldMeasurement.Workload)
		if err != nil {
			return types.ExerciseInformation{}, err
		}
		oldMeasurements = append(oldMeasurements, oldMeasurement)
	}

	information.OldMeasurements = &oldMeasurements

	return information, nil
}

func (db *DB) GetExercisesFromSplitID(userAccountID int, splitID int) ([]types.ExerciseInformation, error) {
	var exercises []types.ExerciseInformation

	query := `
        SELECT e.*
        FROM exercise e
		JOIN exercise_split es ON es.exercise_id = e.id
		JOIN split s ON s.id = es.split_id
		JOIN plan p ON p.id = s.plan_id
		WHERE p.user_id = $1
		AND s.id = $2
		ORDER BY e.id ASC;
    `

	rows, err := db.pool.Query(query, userAccountID, splitID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	oldMeasurementQuery := `
		SELECT s.repetitions, s.workload
		FROM set s
		JOIN workout w ON w.id = s.workout_id
		WHERE s.exercise_id = $1
		AND w.user_id = $2
		AND s.workout_id = (
			SELECT MAX(w.id)
			FROM workout w
			JOIN set s ON s.workout_id = w.id
			WHERE s.exercise_id = $1
			AND w.user_id = $2
		)
		ORDER BY s.order_number ASC;
	`

	for rows.Next() {
		var exercise types.ExerciseInformation
		var oldMeasurements []types.Measurement

		err := rows.Scan(&exercise.ID, &exercise.CreatorID, &exercise.Name, &exercise.TypeID)
		if err != nil {
			return nil, err
		}

		measurementRows, err := db.pool.Query(oldMeasurementQuery, exercise.ID, userAccountID)
		if err != nil {
			return nil, err
		}
		defer measurementRows.Close()

		for measurementRows.Next() {
			var oldMeasurement types.Measurement

			err := measurementRows.Scan(&oldMeasurement.Repetitions, &oldMeasurement.Workload)
			if err != nil {
				return nil, err
			}
			oldMeasurements = append(oldMeasurements, oldMeasurement)
		}

		exercise.OldMeasurements = &oldMeasurements

		exercises = append(exercises, exercise)
	}

	return exercises, nil
}
