package postgres

import (
	"database/sql"
	"flexus/internal/types"
)

func (db DB) CreateUserSettings(tx *sql.Tx, userID types.UserAccountID) error {
	query := `
        INSERT INTO user_settings (user_id, font_size, is_dark_mode, language_id, is_unlisted, is_pull_from_everyone, is_notify_everyone)
        VALUES ($1, $2, $3, $4, $5, $6, $7);
    `
	_, err := tx.Exec(query, userID, 22, false, 1, false, true, true)
	return err
}

func (db DB) GetUserSettings(userID types.UserAccountID) (types.UserSettings, error) {
	query := `
        SELECT *
        FROM user_settings
        WHERE user_id = $1;
    `

	rows, err := db.pool.Query(query, userID)
	if err != nil {
		return types.UserSettings{}, err
	}
	defer rows.Close()

	var settings types.UserSettings

	for rows.Next() {
		err := rows.Scan(
			&settings.ID,
			&settings.UserID,
			&settings.FontSize,
			&settings.IsDarkMode,
			&settings.LanguageID,
			&settings.IsUnlisted,
			&settings.IsPullFromEveryone,
			&settings.PullUserListID,
			&settings.IsNotifyEveryone,
			&settings.NotifyUserListID,
		)
		if err != nil {
			return types.UserSettings{}, err
		}
	}

	if err := rows.Err(); err != nil {
		return types.UserSettings{}, err
	}

	return settings, nil
}
