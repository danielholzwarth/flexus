package middleware

import (
	"context"
	"flexus/internal/types"
	"log"
	"net/http"
	"time"

	"github.com/dgrijalva/jwt-go"
)

var jwtKey = []byte("secret_key")

func ValidateJWT(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("validating jwt on %s", r.URL.Path)

		token := r.Header.Get("flexusjwt")

		if token == "" {
			http.Error(w, "Token is empty", http.StatusBadRequest)
			return
		}

		claims, err := ValdiateToken(token)
		if err != nil {
			http.Error(w, "Resolving token failed", http.StatusBadRequest)
			return
		}

		if time.Until(time.Unix(claims.ExpiresAt, 0)) < 7*24*time.Hour {
			newToken, err := RefreshJWT(claims)
			if err != nil {
				http.Error(w, "Refreshing token failed", http.StatusBadRequest)
				return
			}
			w.Header().Add("flexusjwt", newToken)
		}

		ctx := context.WithValue(r.Context(), types.RequestorContextKey, claims)
		println("useraccountID:", claims.UserAccountID)
		println("username:", claims.Username)

		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func CreateJWT(userAccountID int, username string) (string, error) {
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
