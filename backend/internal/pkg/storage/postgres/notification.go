package postgres

import (
	"flexus/internal/types"
)

func (db *DB) GetNewUsersWorkingOut(userAccountID int) ([]types.NotificationNewUserWorkingOut, error) {
	var users []types.NotificationNewUserWorkingOut

	query := `
        SELECT u.name
        FROM user_account as u
        INNER JOIN friendship as f ON (u.id = f.requestor_id AND $1 = f.requested_id OR $1 = f.requestor_id AND u.id = f.requested_id)
        INNER JOIN workout as w ON u.id = w.user_id
        WHERE u.id != $1 
        AND f.is_accepted = TRUE 
        AND w.created_at > NOW() - INTERVAL '30 seconds' AND w.created_at < NOW();
    `

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var user types.NotificationNewUserWorkingOut

		err := rows.Scan(&user.Username)
		if err != nil {
			return nil, err
		}

		users = append(users, user)
	}

	return users, nil
}
