package notification

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type NotificationStore interface {
	GetNewWorkoutNotifications(userAccountID int) ([]types.NotificationNewUserWorkingOut, error)
}

type service struct {
	handler           http.Handler
	notificationStore NotificationStore
}

func NewService(notificationStore NotificationStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:           r,
		notificationStore: notificationStore,
	}

	r.Get("/", s.getNewWorkoutNotifications())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) getNewWorkoutNotifications() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		users, err := s.notificationStore.GetNewWorkoutNotifications(claims.UserAccountID)
		if err != nil {
			http.Error(w, "Failed to get users", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(users)
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
