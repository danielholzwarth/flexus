package postgres

import (
	"flexus/internal/types"
)

func (db *DB) GetNewWorkoutNotifications(userAccountID int) ([]types.NotificationNewUserWorkingOut, error) {
	var notifications []types.NotificationNewUserWorkingOut

	query := `
	SELECT u.name, w.starttime, COALESCE(g.name, 'null') AS gym_name
	FROM user_account u
	JOIN friendship f ON u.id = f.requestor_id OR u.id = f.requested_id
	JOIN workout w ON u.id = w.user_id
	LEFT JOIN gym g ON g.id = w.gym_id
	JOIN user_settings us ON us.user_id = $1
	WHERE u.id != $1
    AND ($1 = f.requested_id OR $1 = f.requestor_id)
    AND f.is_accepted = TRUE 
    AND w.created_at > NOW() - INTERVAL '30 seconds' 
    AND w.created_at < NOW()
    AND EXISTS (
        SELECT 1 
        FROM user_account_gym uag2
        JOIN user_account u2 ON u2.id = uag2.user_id
        WHERE u2.id = $1
        AND uag2.gym_id = w.gym_id)
    AND (
        us.is_pull_from_everyone = TRUE
        OR EXISTS (
            SELECT 1
            FROM user_account_user_list uaul3
            JOIN user_settings us3 ON us3.pull_user_list_id = uaul3.id
            JOIN user_list ul3 ON uaul3.id = ul3.list_id
            WHERE us3.user_id = $1
            AND ul3.member_id = u.id));
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
