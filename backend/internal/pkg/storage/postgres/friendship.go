package postgres

import (
	"database/sql"
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
        INSERT INTO friendship (created_at, requestor_id, requested_id, is_accepted)
        VALUES (NOW(), $1, $2, $3);
	`

	_, err = db.pool.Exec(query, friendship.RequestorID, friendship.RequestedID, friendship.IsAccepted)

	if err != nil {
		return err
	}

	return nil
}

func (db *DB) GetFriendship(requestorID types.UserAccountID, requestedID types.UserAccountID) (*types.Friendship, error) {
	friendship := &types.Friendship{}

	query := `
		SELECT id, requestor_id, requested_id, is_accepted
		FROM friendship
		WHERE (requestor_id = $1 AND requested_id = $2)
		OR (requestor_id = $2 AND requested_id = $1);
	`

	err := db.pool.QueryRow(query, requestorID, requestedID).Scan(
		&friendship.ID,
		&friendship.RequestorID,
		&friendship.RequestedID,
		&friendship.IsAccepted)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	return friendship, nil
}

func (db *DB) PatchFriendship(requestorID types.UserAccountID, requestedID types.UserAccountID, columnName string, value any) error {
	query := `
		UPDATE friendship
		SET ` + columnName + ` = $3
		WHERE (requestor_id = $1 AND requested_id = $2)
		OR (requestor_id = $2 AND requested_id = $1);
	`

	_, err := db.pool.Exec(query, requestorID, requestedID, value)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("friendship not found")
		}
		return err
	}

	return nil
}

func (db *DB) DeleteFriendship(requestorID types.UserAccountID, requestedID types.UserAccountID) error {
	query := `
		DELETE 
		FROM friendship
		WHERE (requestor_id = $1 AND requested_id = $2)
		OR (requestor_id = $2 AND requested_id = $1);
	`

	_, err := db.pool.Exec(query, requestorID, requestedID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("friendship not found")
		}
		return err
	}

	return nil
}
