package middleware

import (
	"flexus/internal/types"
	"time"

	"github.com/dgrijalva/jwt-go"
)

var jwtKey = []byte("secret_key")

type Claims struct {
	UserID   types.UserAccountID `json:"user_id"`
	Username string              `json:"username"`
	jwt.StandardClaims
}

func CreateJWT(userID types.UserAccountID, username string) (string, error) {
	expirationTime := time.Now().AddDate(0, 1, 0)

	claims := &Claims{
		UserID:   userID,
		Username: username,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: expirationTime.Unix(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtKey)

	if err != nil {
		return "", err
	}

	return tokenString, nil
}

func RefreshJWT() {

}

func GetUserID(tokenString string) (types.UserAccountID, error) {
	claims := &Claims{}

	tkn, err := jwt.ParseWithClaims(tokenString, claims,
		func(t *jwt.Token) (interface{}, error) {
			return jwtKey, nil
		})

	if err != nil {
		if err == jwt.ErrSignatureInvalid {
			return types.UserAccountID(0), err
		}
		return types.UserAccountID(0), err
	}

	if !tkn.Valid {
		return types.UserAccountID(0), err
	}

	return claims.UserID, nil
}
