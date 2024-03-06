package workout

import (
	"encoding/json"
	"flexus/internal/types"
	"fmt"
	"io"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type WorkoutStore interface {
	GetWorkoutOverviews(userAccountID int) ([]types.WorkoutOverview, error)
	PatchWorkout(userAccountID int, workoutID int, columnName string, value any) error
	DeleteWorkout(userAccountID int, workoutID int) error
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
	r.Patch("/{workoutID}", s.patchWorkout())
	r.Delete("/{workoutID}", s.deleteWorkout())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) getWorkoutOverviews() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
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

func (s service) patchWorkout() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		workoutIDValue := chi.URLParam(r, "workoutID")
		workoutID, err := strconv.Atoi(workoutIDValue)
		if err != nil || workoutID <= 0 {
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte("Wrong input for workoutIDInt. Must be integer greater than 0."))
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

		if isArchived, ok := requestBody["isArchived"].(bool); ok {
			fmt.Println("Updating isArchived:", isArchived)

			err = s.workoutStore.PatchWorkout(claims.UserAccountID, workoutID, "is_archived", isArchived)
			if err != nil {
				http.Error(w, "Failed to patch workout", http.StatusInternalServerError)
				println(err.Error())
				return
			}
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}

func (s service) deleteWorkout() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		workoutIDValue := chi.URLParam(r, "workoutID")
		workoutID, err := strconv.Atoi(workoutIDValue)
		if err != nil || workoutID <= 0 {
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte("Wrong input for workoutIDInt. Must be integer greater than 0."))
			return
		}

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
