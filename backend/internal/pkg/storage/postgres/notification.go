package postgres

import (
	"flexus/internal/types"
)

func (db *DB) GetNewUsersWorkingOut(userAccountID int) ([]types.NotificationNewUserWorkingOut, error) {
	var notifications []types.NotificationNewUserWorkingOut

	query := `
		SELECT u.name, w.starttime, COALESCE(g.name, 'null') AS gym_name
		FROM user_account AS u
		JOIN friendship AS f ON u.id = f.requestor_id OR u.id = f.requested_id
		JOIN workout AS w ON u.id = w.user_id
		JOIN gym AS g ON g.id = w.gym_id
		WHERE u.id != $1
		AND ($1 = f.requested_id OR $1 = f.requestor_id)
		AND f.is_accepted = TRUE 
		AND w.created_at > NOW() - INTERVAL '30 seconds' 
		AND w.created_at < NOW()
		AND EXISTS (
			SELECT 1 
			FROM user_account_gym AS uag
			JOIN user_account u2 ON u2.id = uag.user_id
			WHERE u2.id = $1
			AND uag.gym_id = w.gym_id
		);
    `

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var notification types.NotificationNewUserWorkingOut

		err := rows.Scan(&notification.Username, &notification.StartTime, &notification.GymName)
		if err != nil {
			return nil, err
		}

		notifications = append(notifications, notification)
	}

	return notifications, nil
}
