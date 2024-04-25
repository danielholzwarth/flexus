package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
)

func (db *DB) CreatePlan(createPlan types.CreatePlan) error {
	tx, err := db.pool.Begin()
	if err != nil {
		return err
	}

	_, err = tx.Exec(`
		UPDATE plan
		SET is_active = false
		WHERE user_id = $1 AND is_active = true;
	`, createPlan.UserAccountID)
	if err != nil {
		tx.Rollback()
		return err
	}

	var planID int
	err = tx.QueryRow(`
		INSERT INTO plan (user_id, split_count, name, created_at, is_active, is_weekly, is_monday_rest, is_tuesday_rest, is_wednesday_rest, is_thursday_rest, is_friday_rest, is_saturday_rest, is_sunday_rest)
		VALUES ($1, $2, $3, NOW(), true, $4, $5, $6, $7, $8, $9, $10, $11)
		RETURNING id;
	`, createPlan.UserAccountID, createPlan.SplitCount, createPlan.Name, createPlan.IsWeekly, createPlan.RestList[0], createPlan.RestList[1], createPlan.RestList[2], createPlan.RestList[3], createPlan.RestList[4], createPlan.RestList[5], createPlan.RestList[6]).Scan(&planID)
	if err != nil {
		tx.Rollback()
		return err
	}

	for i := 0; i < len(createPlan.Splits); i++ {
		var splitID int
		err := tx.QueryRow(`
			INSERT INTO split (plan_id, name, order_in_plan)
			VALUES ($1, $2, $3)
			RETURNING id;
		`, planID, createPlan.Splits[i], i+1).Scan(&splitID)
		if err != nil {
			tx.Rollback()
			return err
		}

		if createPlan.ExerciseIDs[i] != nil {
			if len(createPlan.ExerciseIDs[i]) > 0 {
				splitExerciseIDs := createPlan.ExerciseIDs[i]

				for j := 0; j < len(splitExerciseIDs); j++ {
					//-1 equals no pre-defined exercises in this split
					if splitExerciseIDs[j] != -1 {
						_, err = tx.Exec(`
						INSERT INTO exercise_split (split_id, exercise_id)
						VALUES ($1, $2);
					`, splitID, splitExerciseIDs[j])
						if err != nil {
							tx.Rollback()
							return err
						}
					}
				}
			}
		}

	}

	if err := tx.Commit(); err != nil {
		return err
	}

	return nil
}

func (db *DB) GetActivePlan(userID int) (types.Plan, error) {
	var plan types.Plan

	query := `
		SELECT * FROM plan
		WHERE user_id = $1 AND is_active = TRUE;
    `

	err := db.pool.QueryRow(query, userID).Scan(
		&plan.ID,
		&plan.UserAccountID,
		&plan.SplitCount,
		&plan.Name,
		&plan.CreatedAt,
		&plan.IsActive,
		&plan.IsWeekly,
		&plan.IsMondayRest,
		&plan.IsTuesdayRest,
		&plan.IsWednesdayRest,
		&plan.IsThursdayRest,
		&plan.IsFridayRest,
		&plan.IsSaturdayRest,
		&plan.IsSundayRest,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return types.Plan{}, nil
		}
		return types.Plan{}, err
	}

	return plan, nil
}

func (db *DB) GetPlansByUserID(userID int) ([]types.Plan, error) {
	var plans []types.Plan

	rows, err := db.pool.Query(`
		SELECT * FROM plan
		WHERE user_id = $1
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var plan types.Plan
		err := rows.Scan(
			&plan.ID,
			&plan.UserAccountID,
			&plan.SplitCount,
			&plan.Name,
			&plan.CreatedAt,
			&plan.IsActive,
			&plan.IsWeekly,
			&plan.IsMondayRest,
			&plan.IsTuesdayRest,
			&plan.IsWednesdayRest,
			&plan.IsThursdayRest,
			&plan.IsFridayRest,
			&plan.IsSaturdayRest,
			&plan.IsSundayRest,
		)
		if err != nil {
			return nil, err
		}
		plans = append(plans, plan)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return plans, nil
}

func (db *DB) DeletePlan(userID int, planID int) error {
	query := `
		DELETE
		FROM plan
		WHERE user_id = $1 AND id = $2;
    `

	_, err := db.pool.Exec(query, userID, planID)
	return err
}

func (db *DB) PatchPlan(userID int, planID int, columnName string, value interface{}) (types.Plan, error) {
	tx, err := db.pool.Begin()
	if err != nil {
		return types.Plan{}, err
	}
	defer tx.Rollback()

	var query string
	var args []interface{}

	if columnName == "is_active" {
		_, err := tx.Exec("UPDATE plan SET is_active = false WHERE user_id = $1 AND is_active = true", userID)
		if err != nil {
			return types.Plan{}, err
		}
	}

	if value == nil {
		query = `
            UPDATE plan
            SET ` + columnName + ` = NULL
            WHERE id = $1 AND user_id = $2;
        `
		args = []interface{}{planID, userID}
	} else {
		query = `
            UPDATE plan
            SET ` + columnName + ` = $1
            WHERE id = $2 AND user_id = $3;
        `
		args = []interface{}{value, planID, userID}
	}

	_, err = tx.Exec(query, args...)
	if err != nil {
		return types.Plan{}, err
	}

	var updatedPlan types.Plan
	err = tx.QueryRow("SELECT * FROM plan WHERE id = $1 AND user_id = $2", planID, userID).Scan(
		&updatedPlan.ID,
		&updatedPlan.UserAccountID,
		&updatedPlan.SplitCount,
		&updatedPlan.Name,
		&updatedPlan.CreatedAt,
		&updatedPlan.IsActive,
		&updatedPlan.IsWeekly,
		&updatedPlan.IsMondayRest,
		&updatedPlan.IsTuesdayRest,
		&updatedPlan.IsWednesdayRest,
		&updatedPlan.IsThursdayRest,
		&updatedPlan.IsFridayRest,
		&updatedPlan.IsSaturdayRest,
		&updatedPlan.IsSundayRest,
	)
	if err != nil {
		return types.Plan{}, err
	}

	err = tx.Commit()
	if err != nil {
		return types.Plan{}, err
	}

	return updatedPlan, nil
}

func (db *DB) PatchPlanExercise(userID int, planID int, splitID int, newExerciseID int, oldExerciseID int) (types.Plan, error) {
	tx, err := db.pool.Begin()
	if err != nil {
		return types.Plan{}, err
	}
	defer tx.Rollback()

	query := `
		SELECT EXISTS(
			SELECT 1
			FROM exercise_split es
			INNER JOIN split s ON s.id = es.split_id
			INNER JOIN plan p ON s.plan_id = p.id
			WHERE es.split_id = $1 AND es.exercise_id = $2 AND p.user_id = $3
		);
	`

	var exists bool
	err = tx.QueryRow(query, splitID, newExerciseID, userID).Scan(&exists)
	if err != nil {
		return types.Plan{}, err
	}

	if !exists {
		query = `
			UPDATE exercise_split es
			SET exercise_id = $1
			FROM split s 
			INNER JOIN plan p ON s.plan_id = p.id
			WHERE es.split_id = $2 AND es.exercise_id = $3 AND p.user_id = $4;
		`

		_, err = tx.Exec(query, newExerciseID, splitID, oldExerciseID, userID)
		if err != nil {
			return types.Plan{}, err
		}
	}

	var updatedPlan types.Plan
	err = tx.QueryRow("SELECT * FROM plan WHERE id = $1 AND user_id = $2;", planID, userID).Scan(
		&updatedPlan.ID,
		&updatedPlan.UserAccountID,
		&updatedPlan.SplitCount,
		&updatedPlan.Name,
		&updatedPlan.CreatedAt,
		&updatedPlan.IsActive,
		&updatedPlan.IsWeekly,
		&updatedPlan.IsMondayRest,
		&updatedPlan.IsTuesdayRest,
		&updatedPlan.IsWednesdayRest,
		&updatedPlan.IsThursdayRest,
		&updatedPlan.IsFridayRest,
		&updatedPlan.IsSaturdayRest,
		&updatedPlan.IsSundayRest,
	)
	if err != nil {
		return types.Plan{}, err
	}

	err = tx.Commit()
	if err != nil {
		return types.Plan{}, err
	}

	return updatedPlan, nil
}

func (db *DB) PatchPlanExercises(userID int, planID int, splitID int, newExercises []int) (types.Plan, error) {
	tx, err := db.pool.Begin()
	if err != nil {
		return types.Plan{}, err
	}
	defer tx.Rollback()

	//Check for valid split
	query := `
		SELECT EXISTS(
			SELECT 1
			FROM split s
			JOIN plan p ON s.plan_id = p.id
			JOIN user_account ua ON ua.id = p.user_id
			WHERE s.id = $1
			AND p.id = $2
			AND ua.id = $3
		);
	`

	var exists bool
	err = tx.QueryRow(query, splitID, planID, userID).Scan(&exists)
	if err != nil {
		return types.Plan{}, err
	}

	//If null return error
	if !exists {
		return types.Plan{}, errors.New("split does not exist")
	}

	//Delete all splits
	_, err = tx.Exec("DELETE FROM exercise_split WHERE split_id = $1;", splitID)
	if err != nil {
		return types.Plan{}, err
	}

	//Create Splits
	for i := 0; i < len(newExercises); i++ {
		_, err = tx.Exec(`
			INSERT INTO exercise_split (split_id, exercise_id)
			VALUES ($1, $2);
		`, splitID, newExercises[i])
		if err != nil {
			return types.Plan{}, err
		}
	}

	var updatedPlan types.Plan
	err = tx.QueryRow("SELECT * FROM plan WHERE id = $1 AND user_id = $2;", planID, userID).Scan(
		&updatedPlan.ID,
		&updatedPlan.UserAccountID,
		&updatedPlan.SplitCount,
		&updatedPlan.Name,
		&updatedPlan.CreatedAt,
		&updatedPlan.IsActive,
		&updatedPlan.IsWeekly,
		&updatedPlan.IsMondayRest,
		&updatedPlan.IsTuesdayRest,
		&updatedPlan.IsWednesdayRest,
		&updatedPlan.IsThursdayRest,
		&updatedPlan.IsFridayRest,
		&updatedPlan.IsSaturdayRest,
		&updatedPlan.IsSundayRest,
	)
	if err != nil {
		return types.Plan{}, err
	}

	err = tx.Commit()
	if err != nil {
		return types.Plan{}, err
	}

	return updatedPlan, nil
}

func (db *DB) GetPlanOverview(userID int) (types.PlanOverview, error) {
	var planOverview types.PlanOverview
	var plan types.Plan

	//Get Plan
	plan, err := db.GetActivePlan(userID)
	if err != nil {
		return types.PlanOverview{}, nil
	}
	planOverview.Plan = plan

	query := `
		SELECT *
		FROM split 
		WHERE plan_id = $1;
	`

	rows, err := db.pool.Query(query, plan.ID)
	if err != nil {
		return types.PlanOverview{}, err
	}
	defer rows.Close()

	var splitOverviews []types.SplitOverview
	for rows.Next() {
		var splitOverview types.SplitOverview
		var split types.Split
		var exercises []types.Exercise
		// var splitMeasurements []string

		err := rows.Scan(
			&split.ID,
			&split.PlanID,
			&split.Name,
			&split.OrderInPlan,
		)
		if err != nil {
			return types.PlanOverview{}, err
		}
		splitOverview.Split = split

		exerciseQuery := `
			SELECT *
			FROM exercise
			JOIN exercise_split ON split_id = $1 AND exercise_id = exercise.id;
		`

		exerciseRows, err := db.pool.Query(exerciseQuery, split.ID)
		if err != nil {
			return types.PlanOverview{}, err
		}
		defer exerciseRows.Close()

		//Anything are the parameters of exercise_split
		var anything any
		for exerciseRows.Next() {
			var exercise types.Exercise
			err := exerciseRows.Scan(
				&exercise.ID,
				&exercise.CreatorID,
				&exercise.Name,
				&exercise.TypeID,
				&anything,
				&anything,
				&anything,
				&anything,
			)
			if err != nil {
				return types.PlanOverview{}, err
			}

			exercises = append(exercises, exercise)
		}

		if err := exerciseRows.Err(); err != nil {
			return types.PlanOverview{}, err
		}

		splitOverview.Exercises = append(splitOverview.Exercises, exercises...)

		// measurementQuery := `
		// 	SELECT measurement
		// 	FROM set
		// 	INNER JOIN workout ON set.workout_id = workout.id
		// 	WHERE workout.user_id = $1
		// 	AND set.exercise_id = $2
		// 	AND workout.id = (
		// 		SELECT MAX(workout_id) 
		// 		FROM set
		// 		INNER JOIN workout ON set.workout_id = workout.id
		// 		WHERE workout.user_id = $1
		// 		AND set.exercise_id = $2
		// 	);
		// `
		// for i := 0; i < len(exercises); i++ {
		// 	measurementRows, err := db.pool.Query(measurementQuery, userID, exercises[i].ID)
		// 	if err != nil {
		// 		return types.PlanOverview{}, err
		// 	}
		// 	defer measurementRows.Close()

		// 	found := measurementRows.Next()
		// 	if !found {
		// 		splitMeasurements = append(splitMeasurements, "none")
		// 	} else {
		// 		var measurement string
		// 		err := measurementRows.Scan(&measurement)
		// 		if err != nil {
		// 			return types.PlanOverview{}, err
		// 		}
		// 		splitMeasurements = append(splitMeasurements, measurement)
		// 	}

		// 	if err := measurementRows.Err(); err != nil {
		// 		return types.PlanOverview{}, err
		// 	}
		// }

		// splitOverview.Measurements = append(splitOverview.Measurements, splitMeasurements)

		splitOverviews = append(splitOverviews, splitOverview)
	}

	if err := rows.Err(); err != nil {
		return types.PlanOverview{}, err
	}

	planOverview.SplitOverviews = splitOverviews

	return planOverview, nil
}
