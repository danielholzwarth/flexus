package postgres

import (
	"database/sql"
	"errors"
)

func (db *DB) BlacklistJWT(tokenString string) error {
	exists, err := db.GetIsTokenBlacklisted(tokenString)
	if err != nil {
		return err
	}

	if exists {
		return errors.New("token already blacklisted")
	}

	query := `
		INSERT INTO blacklist (token, created_at)
		VALUES ($1, NOW());
	`

	_, err = db.pool.Exec(query, tokenString)
	if err != nil {
		return err
	}

	return nil
}

func (db *DB) GetIsTokenBlacklisted(tokenString string) (bool, error) {
	query := `
		SELECT EXISTS (
		SELECT 1
		FROM blacklist
		WHERE token = $1);
	`

	var exists bool
	err := db.pool.QueryRow(query, tokenString).Scan(&exists)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return false, nil
		}
		return true, err
	}

	if exists {
		return true, nil
	}

	return false, nil
}
