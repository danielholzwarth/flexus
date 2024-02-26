package postgres

import (
	"database/sql"
	"errors"
	"flexus/internal/types"
)

func (db *DB) GetUserAccountOverview(userAccountID types.UserAccountID) (types.UserAccountOverview, error) {
	var userAccountOverview types.UserAccountOverview

	query := `
		SELECT ua.id, ua.username, ua.name, ua.created_at, ua.level, ua.profile_picture, ua.bodyweight, g.name
		FROM user_account ua
		LEFT JOIN gender g ON ua.gender_id = g.id
		WHERE ua.id = $1;
	`

	var userAccountInformation types.UserAccountInformation

	err := db.pool.QueryRow(query, userAccountID).Scan(
		&userAccountInformation.UserAccountID,
		&userAccountInformation.Username,
		&userAccountInformation.Name,
		&userAccountInformation.CreatedAt,
		&userAccountInformation.Level,
		&userAccountInformation.ProfilePicture,
		&userAccountInformation.Bodyweight,
		&userAccountOverview.Gender)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return types.UserAccountOverview{}, errors.New("user not found")
		}
		return types.UserAccountOverview{}, err
	}

	var bestLiftOverview []types.BestLiftOverview
	query = `
        SELECT e.name AS "exerciseName", s.repetitions, s.weight, s.duration
        FROM best_lifts bl
        JOIN set s ON bl.set_id = s.id
        JOIN exercise e ON s.exercise_id= e.id
		WHERE bl.user_id = $1
		ORDER BY bl.position_id
		LIMIT 3;
	`

	rows, err := db.pool.Query(query, userAccountID)
	if err != nil {
		return types.UserAccountOverview{}, err
	}
	defer rows.Close()

	for rows.Next() {
		var bestLift types.BestLiftOverview
		if err := rows.Scan(&bestLift.ExerciseName, &bestLift.Repetitions, &bestLift.Weight, &bestLift.Duration); err != nil {
			return types.UserAccountOverview{}, err
		}

		bestLiftOverview = append(bestLiftOverview, bestLift)
	}
	if err := rows.Err(); err != nil {
		return types.UserAccountOverview{}, err
	}

	userAccountOverview.UserAccountInformation = userAccountInformation
	userAccountOverview.BestLiftOverview = bestLiftOverview

	return userAccountOverview, nil
}
