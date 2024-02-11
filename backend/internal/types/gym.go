package types

type GymID uint

type Gym struct {
	ID   GymID  `json:"id"`
	Name string `json:"name"`
	//Location point `json:"location"`
}
