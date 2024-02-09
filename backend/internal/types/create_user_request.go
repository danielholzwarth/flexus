package types 

type CreateUserRequest struct {
	Username            string `json:"username"`
	Name                string `json:"name"`
	PublicKey           string `json:"publicKey"`
	EncryptedPrivateKey string `json:"encryptedPrivateKey"`
	RandomSaltOne       string `json:"randomSaltOne"`
	RandomSaltTwo       string `json:"randomSaltTwo"`
}