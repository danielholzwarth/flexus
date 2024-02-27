package user_account

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type UserAccountStore interface {
	GetUserAccountInformation(userAccountID types.UserAccountID) (types.UserAccountInformation, error)
	PutUserAccount(userAccountInformation types.UserAccountInformation) error
}

type service struct {
	handler          http.Handler
	userAccountStore UserAccountStore
}

func NewService(userAccountStore UserAccountStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:          r,
		userAccountStore: userAccountStore,
	}

	r.Get("/{userAccountID}", s.getUserAccountInformation())
	r.Put("/", s.putUserAccount())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) getUserAccountInformation() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		_, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			return
		}

		userAccountIDValue := chi.URLParam(r, "userAccountID")
		userAccountIDInt, err := strconv.Atoi(userAccountIDValue)
		if err != nil || userAccountIDInt <= 0 {
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte("Wrong input for userAccountIDInt. Must be integer greater than 0."))
			return
		}
		userAccountID := types.UserAccountID(userAccountIDInt)

		userAccountOverview, err := s.userAccountStore.GetUserAccountInformation(userAccountID)
		if err != nil {
			http.Error(w, "Failed to get userAccountOverview", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(userAccountOverview)
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

func (s service) putUserAccount() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequesterContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requester ID", http.StatusInternalServerError)
			println("asd")
			return
		}

		var requestBody types.UserAccountInformation
		decoder := json.NewDecoder(r.Body)
		if err := decoder.Decode(&requestBody); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			println(err.Error())
			return
		}

		if requestBody.UserAccountID <= 0 {
			http.Error(w, "UserAccountID can not be smaller or equal to 0", http.StatusBadRequest)
			println("err")
			return
		}

		if requestBody.Username == "" {
			http.Error(w, "Username can not be empty", http.StatusBadRequest)
			println("err")
			return
		}

		if requestBody.Name == "" {
			http.Error(w, "Name can not be empty", http.StatusBadRequest)
			println("err")
			return
		}

		if requestBody.Level <= 0 {
			http.Error(w, "Level can not be smaller or equal to 0", http.StatusBadRequest)
			println("err")
			return
		}

		if requestBody.UserAccountID != claims.UserAccountID {
			http.Error(w, "You do not have the permissions to update this account", http.StatusBadRequest)
			print("ad")
			return
		}

		err := s.userAccountStore.PutUserAccount(requestBody)
		if err != nil {
			http.Error(w, "Failed to get userAccountOverview", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}
