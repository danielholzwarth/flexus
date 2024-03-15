package postgres

import (
	"database/sql"
	"errors"
)

func (db *DB) PostUserList(userAccountID int, columnName string) (int, error) {
	query := `
        SELECT ` + columnName + `
        FROM user_settings
        WHERE user_id = $1
		AND ` + columnName + ` IS NOT NULL;
    `

	var listID int
	err := db.pool.QueryRow(query, userAccountID).Scan(&listID)
	if err != nil {
		if err == sql.ErrNoRows {
			tx, err := db.pool.Begin()
			if err != nil {
				return -1, err
			}

			defer func() {
				if err != nil {
					tx.Rollback()
					return
				}
			}()

			query := `
				INSERT INTO user_account_user_list (user_id)
				VALUES ($1)
				RETURNING id;
			`
			err = tx.QueryRow(query, userAccountID).Scan(&listID)
			if err != nil {
				return -1, err
			}

			query = `
				UPDATE user_settings 
				SET ` + columnName + ` = $1
				WHERE user_id = $2;
			`
			_, err = tx.Exec(query, listID, userAccountID)
			if err != nil {
				return -1, err
			}

			err = tx.Commit()
			if err != nil {
				return -1, err
			}
		} else {
			return -1, err
		}
	}

	return listID, nil
}

func (db *DB) GetHasUserList(userAccountID int, listID int, userID int) (bool, error) {
	query := `
		SELECT EXISTS (
			SELECT 1
			FROM user_list ul
			LEFT JOIN user_settings us ON us.user_id = $1
			WHERE ul.list_id = $2 AND ul.member_id = $3
		);
	`

	var exists bool
	err := db.pool.QueryRow(query, userAccountID, listID, userID).Scan(&exists)
	if err != nil {
		return false, err
	}

	return exists, nil
}

func (db *DB) PatchUserList(userAccountID int, listID int, userID int) error {
	exists, err := db.GetHasUserList(userAccountID, listID, userID)
	if err != nil {
		return err
	}

	if !exists {
		query := `
			INSERT INTO user_list (list_id, member_id)
			VALUES ($1, $2);
		`

		_, err := db.pool.Exec(query, listID, userID)
		if err != nil {
			return err
		}
	} else {
		query := `
			DELETE 
			FROM user_list
			WHERE member_id = $1 AND list_id = $2;
		`

		_, err := db.pool.Exec(query, userID, listID)
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return errors.New("user_list not found")
			}
			return err
		}
	}

	return nil
}
