package exercise

import (
	"encoding/json"
	parser "flexus/internal/api"
	"flexus/internal/types"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type ExerciseStore interface {
	PostExercise(userAccountID int, name string, typeID int) (types.Exercise, error)
	GetExercises(userAccountID int) ([]types.Exercise, error)
	GetExerciseFromExerciseID(userAccountID int, exerciseID int) (types.ExerciseInformation, error)
	GetExercisesFromSplitID(userAccountID int, splitID int) ([]types.ExerciseInformation, error)
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
	r.Get("/single/{exerciseID}", s.getExerciseFromExerciseID())
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

		bodyData, err := parser.ParseRequestBody(r, map[string]string{"name": "string", "typeID": "int"})
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			println(err.Error())
			return
		}
		name := bodyData["name"].(string)
		typeID := bodyData["typeID"].(int)

		exercise, err := s.exerciseStore.PostExercise(claims.UserAccountID, name, typeID)
		if err != nil {
			http.Error(w, "Failed to create Exercise", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(exercise)
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

func (s service) getExerciseFromExerciseID() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		exerciseIDValue := chi.URLParam(r, "exerciseID")
		exerciseID, err := strconv.Atoi(exerciseIDValue)
		if err != nil || exerciseID <= 0 {
			http.Error(w, "Wrong input for exerciseID. Must be integer greater than 0.", http.StatusBadRequest)
			println(err.Error())
			return
		}

		exercises, err := s.exerciseStore.GetExerciseFromExerciseID(claims.UserAccountID, exerciseID)
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
