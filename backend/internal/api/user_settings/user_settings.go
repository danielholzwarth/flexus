package user_settings

import (
	"encoding/json"
	"flexus/internal/types"
	"io"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type UserSettingsStore interface {
	GetUserSettings(userAccountID int) (types.UserSettings, error)
	PatchUserSettings(columnName string, value any, userAccountID int) error
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
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
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
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		var requestBody map[string]interface{}

		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Error reading request body", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		if err := json.Unmarshal(body, &requestBody); err != nil {
			http.Error(w, "Error parsing request body", http.StatusBadRequest)
			println(err.Error())
			return
		}

		if fontSize, ok := requestBody["font_size"].(float64); ok {
			err = s.userSettingsStore.PatchUserSettings("font_size", fontSize, claims.UserAccountID)
			if err != nil {
				http.Error(w, "Failed to patch fontsize", http.StatusInternalServerError)
				println(err.Error())
				return
			}
		}

		if isDarkMode, ok := requestBody["is_dark_mode"].(bool); ok {
			err := s.userSettingsStore.PatchUserSettings("is_dark_mode", isDarkMode, claims.UserAccountID)
			if err != nil {
				http.Error(w, "Failed to patch darkmode", http.StatusInternalServerError)
				println(err.Error())
				return
			}
		}

		if isQuickAccess, ok := requestBody["is_quick_access"].(bool); ok {
			err := s.userSettingsStore.PatchUserSettings("is_quick_access", isQuickAccess, claims.UserAccountID)
			if err != nil {
				http.Error(w, "Failed to patch quick access", http.StatusInternalServerError)
				println(err.Error())
				return
			}
		}

		if isPullFromEveryone, ok := requestBody["is_pull_from_everyone"].(bool); ok {
			err := s.userSettingsStore.PatchUserSettings("is_pull_from_everyone", isPullFromEveryone, claims.UserAccountID)
			if err != nil {
				http.Error(w, "Failed to patch isPullFromEveryone", http.StatusInternalServerError)
				println(err.Error())
				return
			}
		}

		if isNotifyEveryone, ok := requestBody["is_notify_everyone"].(bool); ok {
			err := s.userSettingsStore.PatchUserSettings("is_notify_everyone", isNotifyEveryone, claims.UserAccountID)
			if err != nil {
				http.Error(w, "Failed to patch isNotifyEveryone", http.StatusInternalServerError)
				println(err.Error())
				return
			}
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}
