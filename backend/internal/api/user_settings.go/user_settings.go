package user_settings

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type UserSettingsStore interface {
	GetUserSettings(userAccountID types.UserAccountID) (types.UserSettings, error)
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
		claims, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			return
		}

		settings, err := s.userSettingsStore.GetUserSettings(claims.UserAccountID)
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
