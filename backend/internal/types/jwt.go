package types

import "github.com/dgrijalva/jwt-go"

var RequestorContextKey = &ContextKey{Key: "requestorID"}

type Claims struct {
	UserAccountID int    `json:"userAccountID"`
	Username      string `json:"username"`
	jwt.StandardClaims
}

type ContextKey struct {
	Key string
}
