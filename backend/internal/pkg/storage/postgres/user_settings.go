package postgres

import (
	"database/sql"
	"flexus/internal/types"
)

func (db DB) CreateUserSettings(tx *sql.Tx, userID types.UserAccountID) error {
    query := `
        INSERT INTO user_settings (user_id, fontsize, is_darkmode, language_id, is_unlisted, is_pull_from_everyone, is_notify_everyone)
        VALUES ($1, $2, $3, $4, $5, $6, $7);
    `
    _, err := tx.Exec(query, userID, 15, false, 1, false, true, true)
    return err
}
