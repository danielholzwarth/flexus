package gym

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type GymStore interface {
	GetGymOverviews(userAccountID types.UserAccountID) ([]types.GymOverview, error)
}

type service struct {
	handler  http.Handler
	gymStore GymStore
}

func NewService(gymStore GymStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:  r,
		gymStore: gymStore,
	}

	r.Get("/", s.getGymOverviews())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) getGymOverviews() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		gymOverviews, err := s.gymStore.GetGymOverviews(claims.UserAccountID)
		if err != nil {
			http.Error(w, "Failed to get GymOverviews", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(gymOverviews)
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
