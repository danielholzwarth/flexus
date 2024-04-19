package postgres

import (
	"database/sql"
	"errors"
)

func (db *DB) PostUserAccountGym(userAccountID int, gymID int) error {
	query := `
        SELECT EXISTS (
			SELECT 1
			FROM user_account_gym
			WHERE user_id = $1 AND gym_id = $2
		);
    `

	var exists bool
	err := db.pool.QueryRow(query, userAccountID, gymID).Scan(&exists)
	if err != nil {
		return err
	}

	if !exists {
		insertQuery := `
			INSERT INTO user_account_gym (user_id, gym_id)
			VALUES ($1, $2);
		`

		_, err = db.pool.Exec(insertQuery, userAccountID, gymID)
		if err != nil {
			return err
		}
		return nil
	} else {
		return errors.New("relation already exists")
	}
}

func (db *DB) GetUserAccountGym(userAccountID int, gymID int) (bool, error) {
	query := `
		SELECT EXISTS (
			SELECT 1
			FROM user_account_gym
			WHERE user_id = $1 AND gym_id = $2
		);
    `
	var exists bool
	err := db.pool.QueryRow(query, userAccountID, gymID).Scan(&exists)
	if err != nil {
		return false, err
	}

	return exists, nil
}

func (db *DB) DeleteUserAccountGym(userAccountID int, gymID int) error {
	tx, err := db.pool.Begin()
	if err != nil {
		return err
	}

	queryDelete := `
		DELETE 
		FROM user_account_gym
		WHERE user_id = $1 AND gym_id = $2;
	`

	_, err = tx.Exec(queryDelete, userAccountID, gymID)
	if err != nil {
		rollbackErr := tx.Rollback()
		if rollbackErr != nil {
			return rollbackErr
		}
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("relation not found")
		}
		return err
	}

	queryUpdateWorkout := `
		UPDATE workout
		SET endtime = NOW()
		WHERE gym_id = $1 AND user_id = $2;
	`

	_, err = tx.Exec(queryUpdateWorkout, gymID, userAccountID)
	if err != nil {
		rollbackErr := tx.Rollback()
		if rollbackErr != nil {
			return rollbackErr
		}
		return err
	}

	err = tx.Commit()
	if err != nil {
		return err
	}

	return nil
}
