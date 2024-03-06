package postgres

import (
	"flexus/internal/types"
)

func (db *DB) GetGymOverviews(userAccountID types.UserAccountID) ([]types.GymOverview, error) {
	var gymOverviews []types.GymOverview

	query := `
        SELECT g.id, g.name, g.country, g.city_name, g.zip_code, g.street_name, g.house_number, g.latitude, g.longitude
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

		err := rows.Scan(&gym.ID, &gym.Name, &gym.Country, &gym.CityName, &gym.ZipCode, &gym.StreetName, &gym.HouseNumber, &gym.Latitude, &gym.Longitude)
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
