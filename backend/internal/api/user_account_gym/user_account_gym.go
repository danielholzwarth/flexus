package user_account_gym

import (
	"encoding/json"
	parser "flexus/internal/api"
	"flexus/internal/types"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type UserAccountGymStore interface {
	PostUserAccountGym(userAccountID int, gymID int) error
	GetUserAccountGym(userAccountID int, gymID int) (bool, error)
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

	r.Post("/", s.postUserAccountGym())
	r.Get("/", s.getUserAccountGym())
	r.Delete("/{gymID}", s.deleteUserAccountGym())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) postUserAccountGym() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		bodyData, err := parser.ParseRequestBody(r, map[string]string{"gymID": "int"})
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			println(err.Error())
			return
		}
		gymID := bodyData["gymID"].(int)

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

func (s service) getUserAccountGym() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		gymIDValue := r.URL.Query().Get("gymID")
		gymID, err := strconv.Atoi(gymIDValue)
		if err != nil || gymID <= 0 {
			http.Error(w, "Wrong input for gymID. Must be integer greater than 0.", http.StatusBadRequest)
			println(err.Error())
			return
		}

		value, err := s.userAccountGymStore.GetUserAccountGym(claims.UserAccountID, gymID)
		if err != nil {
			http.Error(w, "Failed to delete Gym", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(value)
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

func (s service) deleteUserAccountGym() http.HandlerFunc {
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
