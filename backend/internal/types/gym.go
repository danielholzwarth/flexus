package types

type Gym struct {
	ID          int     `json:"id"`
	Name        string  `json:"name"`
	StreetName  string  `json:"streetName"`
	HouseNumber string  `json:"houseNumber"`
	ZipCode     string  `json:"zipCode"`
	CityName    string  `json:"cityName"`
	Latitude    float64 `json:"latitude"`
	Longitude   float64 `json:"longitude"`
}

type GymOverview struct {
	Gym                 Gym                      `json:"gym"`
	CurrentUserAccounts []UserAccountInformation `json:"currentUserAccounts"`
	TotalFriends        int                      `json:"totalFriends"`
}
