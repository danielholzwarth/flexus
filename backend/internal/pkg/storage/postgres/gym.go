package postgres

import (
	"flexus/internal/types"
)

func (db *DB) PostGym(userAccountID int, gym types.Gym) error {
	existsQuery := `
        SELECT COUNT(*)
        FROM gym
        WHERE name = $1 AND latitude = $2 AND longitude = $3;
    `

	var count int
	var id int
	err := db.pool.QueryRow(existsQuery, gym.Name, gym.Latitude, gym.Longitude).Scan(&count)
	if err != nil {
		return err
	}

	tx, err := db.pool.Begin()
	if err != nil {
		return err
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

		err = tx.QueryRow(insertGymQuery, gym.Name, gym.DisplayName, gym.Latitude, gym.Longitude).Scan(&id)
		if err != nil {
			return err
		}
	}

	if count > 0 {
		selectGymIDQuery := `
            SELECT id
            FROM gym
            WHERE name = $1 AND latitude = $2 AND longitude = $3;
        `
		err := db.pool.QueryRow(selectGymIDQuery, gym.Name, gym.Latitude, gym.Longitude).Scan(&id)
		if err != nil {
			return err
		}
	}

	insertUserAccountGymQuery := `
        INSERT INTO user_account_gym (user_id, gym_id)
        VALUES ($1, $2);
    `

	_, err = tx.Exec(insertUserAccountGymQuery, userAccountID, id)
	if err != nil {
		return err
	}

	return nil
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
            SELECT ua.id, ua.username, ua.name, ua.created_at, ua.level, ua.profile_picture, 
                   (SELECT COUNT(*) FROM friendship f WHERE (f.requestor_id = ua.id OR f.requested_id = ua.id) AND f.is_accepted = TRUE) AS friend_count
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

			err := innerRows.Scan(&userAccountInformation.UserAccountID, &userAccountInformation.Username, &userAccountInformation.Name, &userAccountInformation.CreatedAt, &userAccountInformation.Level, &userAccountInformation.ProfilePicture, &gymOverview.TotalFriends)
			if err != nil {
				return nil, err
			}

			userAccountInformations = append(userAccountInformations, userAccountInformation)
		}
		if err := innerRows.Err(); err != nil {
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
