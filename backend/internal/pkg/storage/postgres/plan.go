package postgres

import "flexus/internal/types"

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
