package user_account

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type UserAccountStore interface {
	GetUserAccountOverview(userAccountID types.UserAccountID) (types.UserAccountOverview, error)
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

	r.Get("/{userAccountID}/overview", s.getUserAccountOverview())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) getUserAccountOverview() http.HandlerFunc {
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

		userAccountOverview, err := s.userAccountStore.GetUserAccountOverview(userAccountID)
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
