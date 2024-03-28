package exercise

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type ExerciseStore interface {
	// PostExercise(userAccountID int, exercise types.Exercise) error
	GetExercises(userAccountID int) ([]types.Exercise, error)
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

	// r.Post("/", s.postExercise())
	r.Get("/", s.getExercises())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

// func (s service) postExercise() http.HandlerFunc {
// 	return func(w http.ResponseWriter, r *http.Request) {
// 		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
// 		if !ok {
// 			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
// 			return
// 		}

// 		var requestBody types.Exercise

// 		decoder := json.NewDecoder(r.Body)
// 		if err := decoder.Decode(&requestBody); err != nil {
// 			http.Error(w, err.Error(), http.StatusBadRequest)
// 			println(err.Error())
// 			return
// 		}

// 		//Make check for other variables?
// 		if requestBody.Name == "" {
// 			http.Error(w, "Exercise Name can not be empty", http.StatusBadRequest)
// 			println("Exercise Name can not be empty")
// 			return
// 		}

// 		err := s.exerciseStore.PostExercise(claims.UserAccountID, requestBody)
// 		if err != nil {
// 			http.Error(w, "Failed to create Exercise", http.StatusInternalServerError)
// 			println(err.Error())
// 			return
// 		}

// 		w.Header().Set("Content-Type", "application/json")
// 		w.WriteHeader(http.StatusCreated)
// 	}
// }

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
