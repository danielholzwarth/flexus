package postgres

import "flexus/internal/types"

func (db *DB) CreatePlan(createPlan types.CreatePlan) error {
	query := `
        INSERT INTO plan (user_id, split_count, name, start_date, is_weekly, is_monday_rest, is_tuesday_rest, is_wednesday_rest, is_thursday_rest, is_friday_rest, is_saturday_rest, is_sunday_rest)
        VALUES ($1, $2, $3, NOW(), $4, $5, $6, $7, $8, $9, $10, $11);
	`

	_, err := db.pool.Exec(query,
		createPlan.UserAccountID,
		createPlan.SplitCount,
		createPlan.Name,
		createPlan.IsWeekly,
		createPlan.RestList[0],
		createPlan.RestList[1],
		createPlan.RestList[2],
		createPlan.RestList[3],
		createPlan.RestList[4],
		createPlan.RestList[5],
		createPlan.RestList[6],
	)

	if err != nil {
		return err
	}

	return nil
}
