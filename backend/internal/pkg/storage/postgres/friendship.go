package postgres

import (
	"errors"
	"flexus/internal/types"
)

func (db *DB) CreateFriendship(friendship types.Friendship) error {
	query := `
		SELECT EXISTS (
		SELECT 1
		FROM friendship
		WHERE (requestor_id = $1 AND requested_id = $2)
		OR (requestor_id = $2 AND requested_id = $1)
		);
	`

	var exists bool
	err := db.pool.QueryRow(query, friendship.RequestorID, friendship.RequestedID).Scan(&exists)
	if err != nil {
		return err
	}

	if exists {
		return errors.New("friendship already exists")
	}

	query = `
        INSERT INTO friendship (requestor_id, requested_id, is_accepted)
        VALUES ($1, $2, $3);
	`

	_, err = db.pool.Exec(query, friendship.RequestorID, friendship.RequestedID, friendship.IsAccepted)

	if err != nil {
		return err
	}

	return nil
}
