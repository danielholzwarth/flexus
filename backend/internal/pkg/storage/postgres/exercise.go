package postgres

import (
	"flexus/internal/types"
)

func (db *DB) GetExercises(userAccountID int) ([]types.Exercise, error) {
	var exercises []types.Exercise

	query := `
        SELECT id, creator_id, name, type_id
        FROM exercise
		WHERE creator_id IS NULL OR creator_id = $1;
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
