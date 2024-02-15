package user_settings

import (
	"encoding/json"
	"flexus/internal/api/middleware"
	"flexus/internal/types"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
)

type UserSettingsStore interface {
	GetUserSettings(userID types.UserAccountID) (types.UserSettings, error)
}

type service struct {
	handler           http.Handler
	userSettingsStore UserSettingsStore
}

func NewService(userSettingsStore UserSettingsStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:           r,
		userSettingsStore: userSettingsStore,
	}

	r.Get("/", s.getUserSettings())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) getUserSettings() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get("token")

		if token == "" {
			http.Error(w, "Token cannot be empty", http.StatusBadRequest)
			println(1)
			return
		}

		claims, err := middleware.ValdiateToken(token)
		if err != nil {
			http.Error(w, "Resolving token failed", http.StatusBadRequest)
			println(2)
			return
		}

		//Refresh Token if necessary
		if time.Until(time.Unix(claims.ExpiresAt, 0)) < 7*24*time.Hour {
			newToken, err := middleware.RefreshJWT(claims)
			if err != nil {
				http.Error(w, "Refreshing token failed", http.StatusBadRequest)
				return
			}
			w.Header().Add("newToken", newToken)
		}

		settings, err := s.userSettingsStore.GetUserSettings(claims.UserID)
		if err != nil {
			http.Error(w, "Failed to get availability", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(settings)
		if err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write(response)
	}
}
