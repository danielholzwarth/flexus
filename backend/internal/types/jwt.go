package types

import "github.com/dgrijalva/jwt-go"

type Claims struct {
	UserAccountID UserAccountID `json:"user_id"`
	Username      string        `json:"username"`
	jwt.StandardClaims
}
