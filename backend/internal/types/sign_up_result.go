package types

type SignUpResult struct {
	PublicKey           []byte `json:"publicKey"`
	EncryptedPrivateKey []byte `json:"encryptedPrivateKey"`
	RandomSaltOne       []byte `json:"randomSaltOne"`
	RandomSaltTwo       []byte `json:"randomSaltTwo"`
	VerificationCode    []byte `json:"verificationCode"`
}
