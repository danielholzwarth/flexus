package middleware

import (
	"context"
	"errors"
	"flexus/internal/types"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/dgrijalva/jwt-go"
)

var jwtKey []byte

type MiddlewareStore interface {
	BlacklistJWT(tokenString string) error
	GetIsTokenBlacklisted(tokenString string) (bool, error)
}

type service struct {
	handler         http.Handler
	middlewareStore MiddlewareStore
}

func NewService(middlewareStore MiddlewareStore) service {
	s := service{
		middlewareStore: middlewareStore,
	}

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func init() {
	jwtKey = []byte(os.Getenv("JWT_KEY"))
	if len(jwtKey) == 0 {
		log.Fatalf("JWT_KEY is not set in .env file")
	}
}

func (s service) ValidateJWT(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("validating jwt on %s", r.URL.Path)

		token := r.Header.Get("flexus-jwt")
		if token != "" {

			claims, err := s.ValdiateToken(token)
			if err != nil {
				http.Error(w, "Resolving token failed", http.StatusBadRequest)
				println(err.Error())
				return
			}

			if claims.IsRefresh {
				//Create new Access and Refresh Token and blacklist old refresh token
				newAccessToken, err := CreateAccessToken(claims.UserAccountID, claims.Username)
				if err != nil {
					http.Error(w, "Creating new access token failed", http.StatusInternalServerError)
					println(err.Error())
					return
				}
				newRefreshToken, err := CreateRefreshToken(claims.UserAccountID, claims.Username)
				if err != nil {
					http.Error(w, "Creating new access token failed", http.StatusInternalServerError)
					println(err.Error())
					return
				}

				w.Header().Add("flexus-jwt-access", newAccessToken)
				w.Header().Add("flexus-jwt-refresh", newRefreshToken)

				err = s.middlewareStore.BlacklistJWT(token)
				if err != nil {
					http.Error(w, "Blacklisting token failed", http.StatusInternalServerError)
					println(err.Error())
					return
				}
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
	// expirationTime := time.Now().Add(time.Minute * 1)

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
	// expirationTime := time.Now().Add(time.Minute * 3)

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

func (s service) ValdiateToken(tokenString string) (types.Claims, error) {
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
		return types.Claims{}, errors.New("token is invalid")
	}

	isBlacklisted, err := s.middlewareStore.GetIsTokenBlacklisted(tokenString)
	if err != nil {
		return types.Claims{}, errors.New("checking blacklist failed")
	}

	if isBlacklisted {
		return types.Claims{}, errors.New("token is blacklisted")
	}

	return *claims, nil
}
