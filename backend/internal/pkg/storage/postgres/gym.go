package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
)

func (db *DB) PostGym(userAccountID int, gym types.Gym) (types.Gym, error) {
	existsQuery := `
        SELECT COUNT(*)
        FROM gym
        WHERE name = $1 AND latitude = $2 AND longitude = $3;
    `

	var count int
	err := db.pool.QueryRow(existsQuery, gym.Name, gym.Latitude, gym.Longitude).Scan(&count)
	if err != nil {
		return types.Gym{}, err
	}

	tx, err := db.pool.Begin()
	if err != nil {
		return types.Gym{}, err
	}
	defer func() {
		if err != nil {
			tx.Rollback()
			return
		}
		err = tx.Commit()
	}()

	if count == 0 {
		insertGymQuery := `
            INSERT INTO gym (name, display_name, latitude, longitude)
            VALUES ($1, $2, $3, $4)
            RETURNING id;
        `

		err = tx.QueryRow(insertGymQuery, gym.Name, gym.DisplayName, gym.Latitude, gym.Longitude).Scan(&gym.ID)
		if err != nil {
			return types.Gym{}, err
		}
	}

	if count > 0 {
		selectGymIDQuery := `
            SELECT id
            FROM gym
            WHERE name = $1 AND latitude = $2 AND longitude = $3;
        `
		err := db.pool.QueryRow(selectGymIDQuery, gym.Name, gym.Latitude, gym.Longitude).Scan(&gym.ID)
		if err != nil {
			return types.Gym{}, err
		}
	}

	existsQuery = `
        SELECT COUNT(*)
        FROM user_account_gym
        WHERE user_id = $1 AND gym_id = $2;
    `

	err = db.pool.QueryRow(existsQuery, userAccountID, gym.ID).Scan(&count)
	if err != nil {
		return types.Gym{}, err
	}

	if count == 0 {
		insertUserAccountGymQuery := `
			INSERT INTO user_account_gym (user_id, gym_id)
			VALUES ($1, $2);
		`

		_, err = tx.Exec(insertUserAccountGymQuery, userAccountID, gym.ID)
		if err != nil {
			return types.Gym{}, err
		}
		return gym, nil
	} else {
		return types.Gym{}, errors.New("relation already exists")
	}
}

func (db *DB) GetGymOverviews(userAccountID int) ([]types.GymOverview, error) {
	var gymOverviews []types.GymOverview

	query := `
        SELECT g.id, g.name, g.display_name, g.latitude, g.longitude
        FROM gym g
        INNER JOIN user_account_gym uag ON g.id = uag.gym_id
        WHERE uag.user_id = $1;
    `

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var gymOverview types.GymOverview
		var gym types.Gym

		err := rows.Scan(&gym.ID, &gym.Name, &gym.DisplayName, &gym.Latitude, &gym.Longitude)
		if err != nil {
			return nil, err
		}

		var userAccountInformations []types.UserAccountInformation

		userQuery := `
            SELECT ua.id, ua.username, ua.name, ua.created_at, ua.level, ua.profile_picture
            FROM user_account ua
            INNER JOIN workout w ON ua.id = w.user_id
            WHERE ua.id != $2 AND w.gym_id = $1 AND w.endtime IS NULL AND EXISTS (
                SELECT 1 FROM friendship f WHERE (f.requestor_id = ua.id OR f.requested_id = ua.id) AND f.is_accepted = TRUE AND (
                    f.requestor_id = $2 OR f.requested_id = $2
                )
            );
        `

		innerRows, err := db.pool.Query(userQuery, gym.ID, userAccountID)
		if err != nil {
			return nil, err
		}
		defer innerRows.Close()

		for innerRows.Next() {
			var userAccountInformation types.UserAccountInformation

			err := innerRows.Scan(&userAccountInformation.UserAccountID, &userAccountInformation.Username, &userAccountInformation.Name, &userAccountInformation.CreatedAt, &userAccountInformation.Level, &userAccountInformation.ProfilePicture)
			if err != nil {
				return nil, err
			}

			userAccountInformations = append(userAccountInformations, userAccountInformation)
		}
		if err := innerRows.Err(); err != nil {
			return nil, err
		}

		totalCountQuery := `
			SELECT COUNT(*) 
			FROM user_account ua
			INNER JOIN friendship f ON f.requestor_id = ua.id OR f.requested_id = ua.id
			INNER JOIN workout w ON ua.id = w.user_id
			WHERE ua.id != $1 AND f.is_accepted = TRUE AND w.gym_id = $2;
		`

		err = db.pool.QueryRow(totalCountQuery, userAccountID, gym.ID).Scan(&gymOverview.TotalFriends)
		if err != nil {
			return nil, err
		}

		gymOverview.Gym = gym
		gymOverview.CurrentUserAccounts = userAccountInformations

		gymOverviews = append(gymOverviews, gymOverview)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	return gymOverviews, nil
}

func (db *DB) DeleteGym(userAccountID int, gymID int) error {
	query := `
		DELETE 
		FROM user_account_gym
		WHERE user_id = $1 AND gym_id = $2;
	`

	_, err := db.pool.Exec(query, userAccountID, gymID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return errors.New("relation not found")
		}
		return err
	}

	existQuery := `
		SELECT EXISTS (
			SELECT 1
			FROM user_account_gym
			WHERE gym_id = $1
		);
	`

	var exist bool
	err = db.pool.QueryRow(existQuery, gymID).Scan(&exist)
	if err != nil {
		return err
	}

	if !exist {
		deleteGymQuery := `
			DELETE
			FROM gym
			WHERE id = $1;
		`

		_, err = db.pool.Exec(deleteGymQuery, gymID)
		if err != nil {
			return err
		}
	}
	return nil
}
