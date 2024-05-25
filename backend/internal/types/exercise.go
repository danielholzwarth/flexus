package types

type Exercise struct {
	ID        int    `json:"id"`
	CreatorID *int   `json:"creatorID,omitempty"`
	Name      string `json:"name"`
	TypeID    int    `json:"typeID"`
}

type ExerciseInformation struct {
	ID              int            `json:"id"`
	CreatorID       *int           `json:"creatorID,omitempty"`
	Name            string         `json:"name"`
	TypeID          int            `json:"typeID"`
	OldMeasurements *[]Measurement `json:"oldMeasurements,omitempty"`
}

type NewExerciseInformation struct {
	Exercise        Exercise      `json:"exercise"`
	OldMeasurements []Measurement `json:"oldMeasurements"`
	Measurements    []Measurement `json:"measurements"`
}
