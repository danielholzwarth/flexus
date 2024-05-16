package postgres

func (db *DB) GetTotalMovedWeight(userAccountID int, period int) (any, error) {

	return nil, nil
}

func (db *DB) GetTotalReps(userAccountID int, period int) (any, error) {

	return nil, nil
}

func (db *DB) GetWorkoutDays(userAccountID int, period int) (any, error) {
	query := `
		SELECT COUNT(id), EXTRACT(DOW FROM starttime) AS weekday
		FROM workout
		WHERE user_id = $1
		GROUP BY weekday
		ORDER BY weekday;
	`

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	weekdayCounts := make(map[int]int)
	for rows.Next() {
		var count, weekday int
		err := rows.Scan(&count, &weekday)
		if err != nil {
			return nil, err
		}
		weekdayCounts[weekday] = count
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return weekdayCounts, nil
}

func (db *DB) GetWorkoutDuration(userAccountID int, period int) (any, error) {

	return nil, nil
}
