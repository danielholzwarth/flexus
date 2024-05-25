package postgres

import (
	"strconv"
)

func (db *DB) GetTotalMovedWeight(userAccountID int, period int) (any, error) {

	query := `
		SELECT SUM(s.workload * s.repetitions) AS total_workload, EXTRACT(DOW FROM w.starttime) AS weekday
		FROM workout w
		JOIN set s ON w.id = s.workout_id
		JOIN exercise e ON s.exercise_id = e.id
		WHERE w.user_id = $1 
		AND e.type_id = 1
		AND w.starttime >= CURRENT_DATE - INTERVAL '7 days'
		GROUP BY weekday
		ORDER BY weekday;
	`

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	data := make(map[int]float64)
	for rows.Next() {
		var load float64
		var weekday int
		err := rows.Scan(&load, &weekday)
		if err != nil {
			return nil, err
		}
		data[weekday] = load
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return data, nil
}

func (db *DB) GetTotalReps(userAccountID int, period int) (any, error) {
	query := `
		SELECT SUM(s.repetitions) AS total_repetitions, EXTRACT(DOW FROM w.starttime) AS weekday
		FROM workout w
		JOIN set s ON w.id = s.workout_id
		WHERE w.user_id = $1
		AND w.starttime >= CURRENT_DATE - INTERVAL '7 days'
		GROUP BY weekday
		ORDER BY weekday;
	`

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	data := make(map[int]int)
	for rows.Next() {
		var count, weekday int
		err := rows.Scan(&count, &weekday)
		if err != nil {
			return nil, err
		}
		data[weekday] = count
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return data, nil
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

	data := make(map[int]int)
	for rows.Next() {
		var count, weekday int
		err := rows.Scan(&count, &weekday)
		if err != nil {
			return nil, err
		}
		data[weekday] = count
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return data, nil
}

func (db *DB) GetWorkoutDuration(userAccountID int, period int) (any, error) {
	query := `
        SELECT SUM(EXTRACT(EPOCH FROM (endtime - starttime))) AS total_duration_seconds, EXTRACT(DOW FROM starttime) AS weekday
        FROM workout
        WHERE user_id = $1
		AND starttime >= CURRENT_DATE - INTERVAL '7 days'
        GROUP BY weekday
        ORDER BY weekday;
	`

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	data := make(map[int]int)
	for rows.Next() {
		var weekday int
		var countByte []uint8
		err := rows.Scan(&countByte, &weekday)
		if err != nil {
			return nil, err
		}

		if len(countByte) == 0 {
			data[weekday] = 0
		} else {
			str := string(countByte)

			floatValue, err := strconv.ParseFloat(str, 64)
			if err != nil {
				return nil, err
			}

			data[weekday] = int(floatValue)
		}
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return data, nil
}
