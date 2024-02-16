package types

import "github.com/dgrijalva/jwt-go"

var RequesterContextKey = &ContextKey{Key: "requesterID"}

type Claims struct {
	UserAccountID UserAccountID `json:"userAccountID"`
	Username      string        `json:"username"`
	jwt.StandardClaims
}

type ContextKey struct {
	Key string
}

