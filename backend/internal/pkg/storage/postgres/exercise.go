package postgres

import (
	"errors"
	"flexus/internal/types"
)

func (db *DB) PostExercise(userAccountID int, name string, typeID int) error {
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
		return err
	}

	if exists {
		return errors.New("exercise exists already")
	}

	query = `
		INSERT INTO exercise (creator_id, name, type_id)
		VALUES ($1, $2, $3);
	`

	_, err = db.pool.Exec(query, userAccountID, name, typeID)
	if err != nil {
		return err
	}

	return nil
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
