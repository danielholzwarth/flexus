package gym

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type GymStore interface {
	PostGym(userAccountID int, gym types.Gym) (types.Gym, error)
	GetGymOverviews(userAccountID int) ([]types.GymOverview, error)
	DeleteGym(userAccountID int, gymID int) error
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

	r.Post("/", s.postGym())
	r.Get("/", s.getGymOverviews())
	r.Delete("/{gymID}", s.deleteGym())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) postGym() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		var requestBody types.Gym

		decoder := json.NewDecoder(r.Body)
		if err := decoder.Decode(&requestBody); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			println(err.Error())
			return
		}

		if requestBody.Name == "" {
			http.Error(w, "Gym Name can not be empty", http.StatusBadRequest)
			println("Gym Name can not be empty")
			return
		}

		if requestBody.DisplayName == "" {
			http.Error(w, "Gym DisplayName can not be empty", http.StatusBadRequest)
			println("Gym DisplayName can not be empty")
			return
		}

		gym, err := s.gymStore.PostGym(claims.UserAccountID, requestBody)
		if err != nil {
			http.Error(w, "Failed to create Gym", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(gym)
		if err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		w.Write(response)
	}
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

func (s service) deleteGym() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		gymIDValue := chi.URLParam(r, "gymID")
		gymID, err := strconv.Atoi(gymIDValue)
		if err != nil || gymID <= 0 {
			http.Error(w, "Wrong input for gymID. Must be integer greater than 0.", http.StatusBadRequest)
			println(err.Error())
			return
		}

		err = s.gymStore.DeleteGym(claims.UserAccountID, gymID)
		if err != nil {
			http.Error(w, "Failed to delete Gym", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}
