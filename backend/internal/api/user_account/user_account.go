package user_account

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type UserAccountStore interface {
	CreateUserAccount(createUserRequest types.CreateUserRequest) (types.UserAccount, error)
	GetUsernameAvailability(username string) (bool, error)
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

	r.Post("/", s.createUserAccount())
	r.Get("/", s.getUsernameAvailability())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) createUserAccount() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var requestBody types.CreateUserRequest

		decoder := json.NewDecoder(r.Body)
		if err := decoder.Decode(&requestBody); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			println(err.Error())
			return
		}

		if requestBody.Username == "" {
			http.Error(w, "Username can not be empty", http.StatusBadRequest)
			return
		}

		if requestBody.PublicKey == "" {
			http.Error(w, "PublicKey can not be empty", http.StatusBadRequest)
			return
		}

		if requestBody.EncryptedPrivateKey == "" {
			http.Error(w, "EncryptedPrivateKey can not be empty", http.StatusBadRequest)
			return
		}

		if requestBody.RandomSaltOne == "" {
			http.Error(w, "RandomSaltOne can not be empty", http.StatusBadRequest)
			return
		}

		if requestBody.RandomSaltTwo == "" {
			http.Error(w, "RandomSaltTwo can not be empty", http.StatusBadRequest)
			return
		}

		if requestBody.Name == "" {
			http.Error(w, "Name can not be empty", http.StatusBadRequest)
			return
		}

		user, err := s.userAccountStore.CreateUserAccount(requestBody)
		if err != nil {
			http.Error(w, "Failed to create User", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(user)
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

func (s service) getUsernameAvailability() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		username := r.URL.Query().Get("username")

		if username == "" {
			http.Error(w, "Username can not be empty", http.StatusBadRequest)
			println("as")
			return
		}

		availability, err := s.userAccountStore.GetUsernameAvailability(username)
		if err != nil {
			http.Error(w, "Failed to create User", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(availability)
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
