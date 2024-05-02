package types

type Exercise struct {
	ID        int    `json:"id"`
	CreatorID *int   `json:"creatorID"`
	Name      string `json:"name"`
	TypeID    int    `json:"typeID"`
}

type ExerciseInformation struct {
	ID              int            `json:"id"`
	CreatorID       *int           `json:"creatorID"`
	Name            string         `json:"name"`
	TypeID          int            `json:"typeID"`
	OldMeasurements *[]Measurement `json:"oldMeasurements"`
}
