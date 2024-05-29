package middleware

import (
	"context"
	"flexus/internal/types"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/dgrijalva/jwt-go"
)

var jwtKey []byte

func init() {
	jwtKey = []byte(os.Getenv("JWT_KEY"))
	if len(jwtKey) == 0 {
		log.Fatalf("JWT_KEY is not set in .env file")
	}
}

func ValidateJWT(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("validating jwt on %s", r.URL.Path)

		token := r.Header.Get("flexus-jwt")
		if token != "" {
			claims, err := ValdiateToken(token)
			if err != nil {
				http.Error(w, "Resolving token failed", http.StatusBadRequest)
				println(err.Error())
				return
			}

			if claims.IsRefresh {
				//Create new Access and Refresh Token
				newAccessToken, err := CreateAccessToken(claims.UserAccountID, claims.Username)
				if err != nil {
					http.Error(w, "Creating new access token failed", http.StatusBadRequest)
					println(err.Error())
					return
				}
				newRefreshToken, err := CreateRefreshToken(claims.UserAccountID, claims.Username)
				if err != nil {
					http.Error(w, "Creating new access token failed", http.StatusBadRequest)
					println(err.Error())
					return
				}

				w.Header().Add("flexus-jwt-access", newAccessToken)
				w.Header().Add("flexus-jwt-refresh", newRefreshToken)
			}

			ctx := context.WithValue(r.Context(), types.RequestorContextKey, claims)
			println("Request of: useraccountID", claims.UserAccountID, "- username", claims.Username)

			next.ServeHTTP(w, r.WithContext(ctx))
			return
		}

		http.Error(w, "Token is empty", http.StatusBadRequest)
		println("Token is empty")
	})
}

func CreateAccessToken(userAccountID int, username string) (string, error) {
	expirationTime := time.Now().AddDate(0, 0, 1)

	claims := &types.Claims{
		UserAccountID: userAccountID,
		Username:      username,
		IsRefresh:     false,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: expirationTime.Unix(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		println(err.Error())
		return "", err
	}

	return tokenString, nil
}

func CreateRefreshToken(userAccountID int, username string) (string, error) {
	expirationTime := time.Now().AddDate(0, 0, 28)

	claims := &types.Claims{
		UserAccountID: userAccountID,
		Username:      username,
		IsRefresh:     true,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: expirationTime.Unix(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		println(err.Error())
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
			println(err.Error())
			return types.Claims{}, err
		}
		println(err.Error())
		return types.Claims{}, err
	}

	if !tkn.Valid {
		return types.Claims{}, err
	}

	return *claims, nil
}
