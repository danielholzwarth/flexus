package notification

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type NotificationStore interface {
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

	r.Get("/", s.fetchData())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) fetchData() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		response, err := json.Marshal(claims.UserAccountID)
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
