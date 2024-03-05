package types

type GymID uint

type Gym struct {
	ID          GymID   `json:"id"`
	Name        string  `json:"name"`
	Country     string  `json:"country"`
	CityName    string  `json:"cityName"`
	ZipCode     string  `json:"zipCode"`
	StreetName  string  `json:"streetName"`
	HouseNumber string  `json:"houseNumber"`
	Latitude    float64 `json:"latitude"`
	Longitude   float64 `json:"longitude"`
}

type GymOverview struct {
	Gym                 Gym                      `json:"gym"`
	CurrentUserAccounts []UserAccountInformation `json:"currentUserAccounts"`
	TotalFriends        int                      `json:"totalFriends"`
}
