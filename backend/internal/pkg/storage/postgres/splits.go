package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
)

func (db *DB) GetSplitsFromPlanID(userAccountID int, planID int) ([]types.Split, error) {
	var splits []types.Split

	query := `
        SELECT s.*
        FROM split s
		JOIN plan p ON p.id = s.plan_id
        WHERE s.plan_id = $1
        AND p.user_id = $2
		ORDER BY s.order_in_plan DESC;
	`

	rows, err := db.pool.Query(query, planID, userAccountID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return []types.Split{}, nil
		}
		return []types.Split{}, err
	}
	defer rows.Close()

	for rows.Next() {
		var split types.Split
		if err := rows.Scan(&split.ID, &split.PlanID, &split.Name, &split.OrderInPlan); err != nil {
			return []types.Split{}, err
		}

		splits = append(splits, split)
	}
	if err := rows.Err(); err != nil {
		return []types.Split{}, err
	}

	return splits, nil
}
