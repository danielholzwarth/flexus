package types

type CreateUserRequest struct {
	Username            string `json:"username"`
	Name                string `json:"name"`
	PublicKey           []byte `json:"publicKey"`
	EncryptedPrivateKey []byte `json:"encryptedPrivateKey"`
	RandomSaltOne       []byte `json:"randomSaltOne"`
	RandomSaltTwo       []byte `json:"randomSaltTwo"`
	//SignupResult
}
