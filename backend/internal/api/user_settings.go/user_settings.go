package user_settings

import (
	"encoding/json"
	"flexus/internal/types"
	"fmt"
	"io"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type UserSettingsStore interface {
	GetUserSettings(userAccountID types.UserAccountID) (types.UserSettings, error)
	PatchUserSettings(columnName string, value any, userAccountID types.UserAccountID) error
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
	r.Patch("/", s.patchUserSettings())

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

func (s service) patchUserSettings() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			return
		}

		var requestBody map[string]interface{}

		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Error reading request body", http.StatusInternalServerError)
			return
		}

		if err := json.Unmarshal(body, &requestBody); err != nil {
			http.Error(w, "Error parsing request body", http.StatusBadRequest)
			return
		}

		if fontSize, ok := requestBody["font_size"].(float64); ok {
			fmt.Println("Updating fontsize:", fontSize)

			err = s.userSettingsStore.PatchUserSettings("font_size", fontSize, claims.UserAccountID)
			if err != nil {
				http.Error(w, "Failed to patch userAccount", http.StatusInternalServerError)
				println(err.Error())
				return
			}
		}

		if isDarkMode, ok := requestBody["is_dark_mode"].(bool); ok {
			fmt.Println("Updating darkmode:", isDarkMode)
			err := s.userSettingsStore.PatchUserSettings("is_dark_mode", isDarkMode, claims.UserAccountID)
			if err != nil {
				http.Error(w, "Failed to patch userAccount", http.StatusInternalServerError)
				println(err.Error())
				return
			}
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}
