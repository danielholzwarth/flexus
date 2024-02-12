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
	GetSignUpResult(username string) (types.SignUpResult, error)
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
	r.Get("/availability", s.getUsernameAvailability())
	r.Get("/signUpResult", s.getSignUpResult())

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

		availability, err := s.userAccountStore.GetUsernameAvailability(requestBody.Username)
		if err != nil {
			http.Error(w, "Failed to create User", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		if !availability {
			http.Error(w, "Username is already assigned", http.StatusBadRequest)
			return
		}

		if len(requestBody.PublicKey) == 0 {
			http.Error(w, "PublicKey can not be empty", http.StatusBadRequest)
			return
		}

		if len(requestBody.EncryptedPrivateKey) == 0 {
			http.Error(w, "EncryptedPrivateKey can not be empty", http.StatusBadRequest)
			return
		}

		if len(requestBody.RandomSaltOne) == 0 {
			http.Error(w, "RandomSaltOne can not be empty", http.StatusBadRequest)
			return
		}

		if len(requestBody.RandomSaltTwo) == 0 {
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
			return
		}

		if len(username) > 20 {
			http.Error(w, "Username can not be longer than 20 characters", http.StatusBadRequest)
			return
		}

		availability, err := s.userAccountStore.GetUsernameAvailability(username)
		if err != nil {
			http.Error(w, "Failed to get availability", http.StatusInternalServerError)
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

func (s service) getSignUpResult() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		username := r.URL.Query().Get("username")

		if username == "" {
			http.Error(w, "Username can not be empty", http.StatusBadRequest)
			return
		}

		if len(username) > 20 {
			http.Error(w, "Username can not be longer than 20 characters", http.StatusBadRequest)
			return
		}

		availability, err := s.userAccountStore.GetSignUpResult(username)
		if err != nil {
			http.Error(w, "Failed to get availability", http.StatusInternalServerError)
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
