package workout

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type WorkoutStore interface {
	GetWorkouts(userAccountID types.UserAccountID) ([]types.Workout, error)
	GetSearchedWorkouts(userAccountID types.UserAccountID, keyWord string) ([]types.Workout, error)
	GetArchivedWorkouts(userAccountID types.UserAccountID) ([]types.Workout, error)
	GetSearchedArchivedWorkouts(userAccountID types.UserAccountID, keyWord string) ([]types.Workout, error)
}

type service struct {
	handler      http.Handler
	workoutStore WorkoutStore
}

func NewService(workoutStore WorkoutStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:      r,
		workoutStore: workoutStore,
	}

	r.Get("/", s.getWorkouts())
	r.Get("/search", s.getSearchedWorkouts())
	r.Get("/archive", s.getArchivedWorkouts())
	r.Get("/archive/search", s.getSearchedArchivedWorkouts())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) getWorkouts() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			return
		}

		workouts, err := s.workoutStore.GetWorkouts(claims.UserAccountID)
		if err != nil {
			http.Error(w, "Failed to get workouts", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(workouts)
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

func (s service) getSearchedWorkouts() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			return
		}

		keyWord := r.URL.Query().Get("keyword")

		workouts, err := s.workoutStore.GetSearchedWorkouts(claims.UserAccountID, keyWord)
		if err != nil {
			http.Error(w, "Failed to get workouts", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(workouts)
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

func (s service) getArchivedWorkouts() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			return
		}

		workouts, err := s.workoutStore.GetArchivedWorkouts(claims.UserAccountID)
		if err != nil {
			http.Error(w, "Failed to get workouts", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(workouts)
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

func (s service) getSearchedArchivedWorkouts() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			return
		}

		keyWord := r.URL.Query().Get("keyword")

		workouts, err := s.workoutStore.GetSearchedArchivedWorkouts(claims.UserAccountID, keyWord)
		if err != nil {
			http.Error(w, "Failed to get workouts", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(workouts)
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
