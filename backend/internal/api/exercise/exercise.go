package exercise

import (
	"encoding/json"
	"flexus/internal/types"
	"io"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type ExerciseStore interface {
	PostExercise(userAccountID int, name string, typeID int) error
	GetExercises(userAccountID int) ([]types.Exercise, error)
	GetExercisesFromSplitID(userAccountID int, splitID int) ([]types.Exercise, error)
}

type service struct {
	handler       http.Handler
	exerciseStore ExerciseStore
}

func NewService(exerciseStore ExerciseStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:       r,
		exerciseStore: exerciseStore,
	}

	r.Post("/", s.postExercise())
	r.Get("/", s.getExercises())
	r.Get("/{splitID}", s.getExercisesFromSplitID())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) postExercise() http.HandlerFunc {
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

		name, ok := requestBody["name"].(string)
		if !ok {
			http.Error(w, "Error parsing name", http.StatusInternalServerError)
			println("Error parsing name")
			return
		}

		typeIDFloat, ok := requestBody["typeID"].(float64)
		if !ok {
			http.Error(w, "Error parsing typeID", http.StatusInternalServerError)
			println("Error parsing typeID")
			return
		}
		typeID := int(typeIDFloat)

		err = s.exerciseStore.PostExercise(claims.UserAccountID, name, typeID)
		if err != nil {
			http.Error(w, "Failed to create Exercise", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
	}
}

func (s service) getExercises() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		exercises, err := s.exerciseStore.GetExercises(claims.UserAccountID)
		if err != nil {
			http.Error(w, "Failed to get Exercises", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(exercises)
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

func (s service) getExercisesFromSplitID() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		splitIDValue := chi.URLParam(r, "splitID")
		splitID, err := strconv.Atoi(splitIDValue)
		if err != nil || splitID <= 0 {
			http.Error(w, "Wrong input for splitID. Must be integer greater than 0.", http.StatusBadRequest)
			println(err.Error())
			return
		}

		exercises, err := s.exerciseStore.GetExercisesFromSplitID(claims.UserAccountID, splitID)
		if err != nil {
			http.Error(w, "Failed to get Exercises", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(exercises)
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
