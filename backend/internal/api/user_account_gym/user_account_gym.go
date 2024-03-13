package user_account_gym

import (
	"encoding/json"
	"flexus/internal/types"
	"io"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type UserAccountGymStore interface {
	PostUserAccountGym(userAccountID int, gymID int) error
	DeleteUserAccountGym(userAccountID int, gymID int) error
}

type service struct {
	handler             http.Handler
	userAccountGymStore UserAccountGymStore
}

func NewService(userAccountGymStore UserAccountGymStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:             r,
		userAccountGymStore: userAccountGymStore,
	}

	r.Post("/", s.postGym())
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

		gymIDFloat, ok := requestBody["gymID"].(float64)
		if !ok {
			http.Error(w, "Invalid type for gymID", http.StatusBadRequest)
			println("Invalid type for gymID")
			return
		}

		gymID := int(gymIDFloat)
		if gymID <= 0 {
			http.Error(w, "Wrong input for gymID. Must be integer greater than 0.", http.StatusBadRequest)
			println("Wrong input for gymID. Must be integer greater than 0.")
			return
		}

		err = s.userAccountGymStore.PostUserAccountGym(claims.UserAccountID, gymID)
		if err != nil {
			http.Error(w, "Failed to create Gym", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
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

		err = s.userAccountGymStore.DeleteUserAccountGym(claims.UserAccountID, gymID)
		if err != nil {
			http.Error(w, "Failed to delete Gym", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}
