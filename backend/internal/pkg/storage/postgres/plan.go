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
		WHERE user_id = $1 AND is_active = true
	`, createPlan.UserAccountID)
	if err != nil {
		tx.Rollback()
		return err
	}

	_, err = tx.Exec(`
		INSERT INTO plan (user_id, split_count, name, created_at, is_active, is_weekly, is_monday_rest, is_tuesday_rest, is_wednesday_rest, is_thursday_rest, is_friday_rest, is_saturday_rest, is_sunday_rest)
		VALUES ($1, $2, $3, NOW(), true, $4, $5, $6, $7, $8, $9, $10, $11)
	`, createPlan.UserAccountID, createPlan.SplitCount, createPlan.Name, createPlan.IsWeekly, createPlan.RestList[0], createPlan.RestList[1], createPlan.RestList[2], createPlan.RestList[3], createPlan.RestList[4], createPlan.RestList[5], createPlan.RestList[6])
	if err != nil {
		tx.Rollback()
		return err
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
