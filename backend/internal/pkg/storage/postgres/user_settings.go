package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
)

func (db DB) CreateUserSettings(tx *sql.Tx, userAccountID int) error {
	query := `
        INSERT INTO user_settings (user_id, font_size, is_dark_mode, language_id, is_unlisted, is_pull_from_everyone, is_notify_everyone, is_quick_access)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8);
    `
	_, err := tx.Exec(query, userAccountID, 22.0, false, 1, false, true, true, false)
	return err
}

func (db DB) GetUserSettings(userAccountID int) (types.UserSettings, error) {
	query := `
        SELECT *
        FROM user_settings
        WHERE user_id = $1;
    `

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return types.UserSettings{}, err
	}
	defer rows.Close()

	var settings types.UserSettings

	for rows.Next() {
		err := rows.Scan(
			&settings.ID,
			&settings.UserAccountID,
			&settings.FontSize,
			&settings.IsDarkMode,
			&settings.LanguageID,
			&settings.IsUnlisted,
			&settings.IsPullFromEveryone,
			&settings.PullUserListID,
			&settings.IsNotifyEveryone,
			&settings.NotifyUserListID,
			&settings.IsQuickAccess,
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

func (db *DB) PatchUserSettings(columnName string, value any, userAccountID int) error {
	query := `
		UPDATE user_settings
		SET ` + columnName + ` = $1
		WHERE user_id = $2;
	`

	_, err := db.pool.Exec(query, value, userAccountID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("user not found")
		}
		return err
	}

	return nil
}

func (db *DB) PatchEntireUserSettings(userAccountID int, userSettings types.UserSettings) error {
	query := `
		UPDATE user_settings
		SET font_size = $2, is_dark_mode = $3, is_unlisted = $4, is_pull_from_everyone = $5, is_notify_everyone = $6, is_quick_access = $7
		WHERE user_id = $1;
	`

	_, err := db.pool.Exec(
		query,
		userAccountID,
		userSettings.FontSize,
		userSettings.IsDarkMode,
		userSettings.IsUnlisted,
		userSettings.IsPullFromEveryone,
		userSettings.IsNotifyEveryone,
		userSettings.IsQuickAccess,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("userSettings not found")
		}
		return err
	}

	return nil
}
