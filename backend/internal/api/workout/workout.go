package workout

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type WorkoutStore interface {
	GetWorkoutOverviews(userAccountID types.UserAccountID) ([]types.WorkoutOverview, error)
	GetSearchedWorkoutOverviews(userAccountID types.UserAccountID, keyWord string) ([]types.WorkoutOverview, error)
	GetArchivedWorkoutOverviews(userAccountID types.UserAccountID) ([]types.WorkoutOverview, error)
	GetSearchedArchivedWorkoutOverviews(userAccountID types.UserAccountID, keyWord string) ([]types.WorkoutOverview, error)
	PutWorkoutArchiveStatus(userAccountID types.UserAccountID, workoutID types.WorkoutID) ([]types.WorkoutOverview, error)
	DeleteWorkout(userAccountID types.UserAccountID, workoutID types.WorkoutID) error
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

	r.Get("/", s.getWorkoutOverviews())
	r.Get("/search", s.getSearchedWorkoutOverviews())
	r.Get("/archive", s.getArchivedWorkoutOverviews())
	r.Get("/archive/search", s.getSearchedArchivedWorkoutOverviews())
	r.Put("/{workoutID}", s.putWorkoutArchiveStatus())
	r.Delete("/{workoutID}", s.deleteWorkout())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) getWorkoutOverviews() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			return
		}

		workoutOverviews, err := s.workoutStore.GetWorkoutOverviews(claims.UserAccountID)
		if err != nil {
			http.Error(w, "Failed to get WorkoutOverview", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(workoutOverviews)
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

func (s service) getSearchedWorkoutOverviews() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			return
		}

		keyWord := r.URL.Query().Get("keyword")

		workoutOverviews, err := s.workoutStore.GetSearchedWorkoutOverviews(claims.UserAccountID, keyWord)
		if err != nil {
			http.Error(w, "Failed to get workouts", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(workoutOverviews)
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

func (s service) getArchivedWorkoutOverviews() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			return
		}

		workoutOverviews, err := s.workoutStore.GetArchivedWorkoutOverviews(claims.UserAccountID)
		if err != nil {
			http.Error(w, "Failed to get workouts", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(workoutOverviews)
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

func (s service) getSearchedArchivedWorkoutOverviews() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			return
		}

		keyWord := r.URL.Query().Get("keyword")

		workoutOverviews, err := s.workoutStore.GetSearchedArchivedWorkoutOverviews(claims.UserAccountID, keyWord)
		if err != nil {
			http.Error(w, "Failed to get workouts", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(workoutOverviews)
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

func (s service) putWorkoutArchiveStatus() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			return
		}

		workoutIDValue := chi.URLParam(r, "workoutID")
		workoutIDInt, err := strconv.Atoi(workoutIDValue)
		if err != nil || workoutIDInt <= 0 {
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte("Wrong input for workoutIDInt. Must be integer greater than 0."))
			return
		}

		workoutID := types.WorkoutID(workoutIDInt)

		workoutOverviews, err := s.workoutStore.PutWorkoutArchiveStatus(claims.UserAccountID, workoutID)
		if err != nil {
			http.Error(w, "Failed to get WorkoutOverview", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(workoutOverviews)
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

func (s service) deleteWorkout() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			return
		}

		workoutIDValue := chi.URLParam(r, "workoutID")
		workoutIDInt, err := strconv.Atoi(workoutIDValue)
		if err != nil || workoutIDInt <= 0 {
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte("Wrong input for workoutIDInt. Must be integer greater than 0."))
			return
		}
		workoutID := types.WorkoutID(workoutIDInt)

		err = s.workoutStore.DeleteWorkout(claims.UserAccountID, workoutID)
		if err != nil {
			http.Error(w, "Failed to get WorkoutOverview", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}
