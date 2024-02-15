package types

import "github.com/dgrijalva/jwt-go"

type Claims struct {
	UserID   UserAccountID `json:"user_id"`
	Username string        `json:"username"`
	jwt.StandardClaims
}
