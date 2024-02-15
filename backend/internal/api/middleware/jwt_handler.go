package middleware

import (
	"flexus/internal/types"
	"time"

	"github.com/dgrijalva/jwt-go"
)

var jwtKey = []byte("secret_key")

func CreateJWT(userAccountID types.UserAccountID, username string) (string, error) {
	expirationTime := time.Now().AddDate(0, 1, 0)
	//expirationTime := time.Now().Add(time.Minute)

	claims := &types.Claims{
		UserAccountID: userAccountID,
		Username:      username,
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

func RefreshJWT(claims types.Claims) (string, error) {
	expirationTime := time.Now().AddDate(0, 1, 0)
	//expirationTime := time.Now().Add(time.Minute)

	claims.ExpiresAt = expirationTime.Unix()

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

func ValdiateToken(tokenString string) (types.Claims, error) {
	claims := &types.Claims{}

	tkn, err := jwt.ParseWithClaims(tokenString, claims,
		func(t *jwt.Token) (interface{}, error) {
			return jwtKey, nil
		})

	if err != nil {
		if err == jwt.ErrSignatureInvalid {
			return types.Claims{}, err
		}
		return types.Claims{}, err
	}

	if !tkn.Valid {
		return types.Claims{}, err
	}

	return *claims, nil
}
