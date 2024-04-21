package postgres

import (
	"flexus/internal/types"
)

func (db *DB) PostGym(userAccountID int, gym types.Gym) error {
	exists, err := db.GetGymExists(gym.Name, gym.Latitude, gym.Longitude)
	if err != nil {
		return err
	}

	if !exists {
		insertGymQuery := `
            INSERT INTO gym (name, street_name, house_number, zip_code, city_name, latitude, longitude)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING id;
        `

		err = db.pool.QueryRow(insertGymQuery, gym.Name, &gym.StreetName, &gym.HouseNumber, &gym.ZipCode, &gym.CityName, gym.Latitude, gym.Longitude).Scan(&gym.ID)
		if err != nil {
			return err
		}
	}

	return nil
}

func (db *DB) GetGymExists(name string, lat float64, lon float64) (bool, error) {
	query := `
        SELECT EXISTS(
			SELECT 1
			FROM gym
			WHERE name = $1 AND latitude = $2 AND longitude = $3
		);
    `

	var exists bool
	err := db.pool.QueryRow(query, name, lat, lon).Scan(&exists)
	if err != nil {
		return false, err
	}

	return exists, nil
}

func (db *DB) GetGymsSearch(keyword string) ([]types.Gym, error) {
	var gyms []types.Gym

	query := `
        SELECT id, name, street_name, house_number, zip_code, city_name, latitude, longitude
        FROM gym
		WHERE (LOWER(name) LIKE '%' || LOWER($1) || '%');
    `

	rows, err := db.pool.Query(query, keyword)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var gym types.Gym

		err := rows.Scan(&gym.ID, &gym.Name, &gym.StreetName, &gym.HouseNumber, &gym.ZipCode, &gym.CityName, &gym.Latitude, &gym.Longitude)
		if err != nil {
			return nil, err
		}

		gyms = append(gyms, gym)
	}

	return gyms, nil
}

func (db *DB) GetGymOverviews(userAccountID int) ([]types.GymOverview, error) {
	var gymOverviews []types.GymOverview

	query := `
        SELECT g.id, g.name, g.street_name, g.house_number, g.zip_code, g.city_name, g.latitude, g.longitude
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

		err := rows.Scan(&gym.ID, &gym.Name, &gym.StreetName, &gym.HouseNumber, &gym.ZipCode, &gym.CityName, &gym.Latitude, &gym.Longitude)
		if err != nil {
			return nil, err
		}

		var userAccountInformations []types.UserAccountInformation

		userQuery := `
			SELECT DISTINCT ua.id, ua.username, ua.name, ua.created_at, ua.level, ua.profile_picture
			FROM user_account ua
			JOIN workout ON ua.id = workout.user_id
			JOIN friendship ON friendship.requestor_id = ua.id OR friendship.requested_id = ua.id
			WHERE workout.gym_id = $1
			AND workout.endtime IS NULL 
			AND (friendship.requestor_id = $2 OR friendship.requested_id = $2)
			AND friendship.is_accepted = TRUE;
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
			FROM user_account_gym uag
			JOIN user_account ON user_account.id = uag.user_id
			JOIN friendship ON friendship.requestor_id = user_account.id OR friendship.requested_id = user_account.id
			WHERE uag.user_id != $1 
				AND uag.gym_id = $2
				AND (friendship.requestor_id = $1 OR friendship.requested_id = $1)
				AND friendship.is_accepted = TRUE;
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
