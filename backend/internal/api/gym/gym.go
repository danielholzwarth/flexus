package gym

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type GymStore interface {
	PostGym(userAccountID int, gym types.Gym) error
	GetGymExisting(name string, lat float64, lon float64) (bool, error)
	GetGymsSearch(keyword string) ([]types.Gym, error)
	GetMyGyms(userAccountID int, keyword string) ([]types.Gym, error)
	GetGymOverviews(userAccountID int) ([]types.GymOverview, error)
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
	r.Get("/exists", s.getGymExisting())
	r.Get("/", s.getMyGyms())
	r.Get("/search", s.getGymsSearch())
	r.Get("/overviews", s.getGymOverviews())

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

		err := s.gymStore.PostGym(claims.UserAccountID, requestBody)
		if err != nil {
			http.Error(w, "Failed to create Gym", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
	}
}

func (s service) getGymExisting() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		_, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		name := r.URL.Query().Get("name")

		latStr := r.URL.Query().Get("lat")
		lat, err := strconv.ParseFloat(latStr, 64)
		if err != nil {
			http.Error(w, "Invalid latitude", http.StatusBadRequest)
			return
		}

		lonStr := r.URL.Query().Get("lon")
		lon, err := strconv.ParseFloat(lonStr, 64)
		if err != nil {
			http.Error(w, "Invalid longitude", http.StatusBadRequest)
			return
		}

		exists, err := s.gymStore.GetGymExisting(name, lat, lon)
		if err != nil {
			http.Error(w, "Failed to get Gyms", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(exists)
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

func (s service) getGymsSearch() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		_, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		keyword := r.URL.Query().Get("keyword")

		gyms, err := s.gymStore.GetGymsSearch(keyword)
		if err != nil {
			http.Error(w, "Failed to get Gyms", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(gyms)
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

func (s service) getMyGyms() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		keyword := r.URL.Query().Get("keyword")

		gyms, err := s.gymStore.GetMyGyms(claims.UserAccountID, keyword)
		if err != nil {
			http.Error(w, "Failed to get Gyms", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(gyms)
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
