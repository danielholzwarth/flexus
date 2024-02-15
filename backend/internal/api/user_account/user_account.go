package user_account

import (
	"encoding/json"
	"flexus/internal/api/middleware"
	"flexus/internal/types"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type UserAccountStore interface {
	CreateUserAccount(createUserRequest types.CreateUserRequest) (types.UserAccount, error)
	GetUsernameAvailability(username string) (bool, error)
	GetLoginUser(username string, password string) (types.UserAccount, error)
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
	r.Get("/login", s.getLoginUser())

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
			return
		}

		if requestBody.Username == "" {
			http.Error(w, "Username can not be empty", http.StatusBadRequest)
			return
		}

		if requestBody.Name == "" {
			http.Error(w, "Name can not be empty", http.StatusBadRequest)
			return
		}

		if requestBody.Password == "" {
			http.Error(w, "Password can not be empty", http.StatusBadRequest)
			return
		}

		availability, err := s.userAccountStore.GetUsernameAvailability(requestBody.Username)
		if err != nil {
			http.Error(w, "Failed to create User", http.StatusInternalServerError)
			return
		}

		if !availability {
			http.Error(w, "Username is already assigned", http.StatusBadRequest)
			return
		}

		user, err := s.userAccountStore.CreateUserAccount(requestBody)
		if err != nil {
			http.Error(w, "Failed to create User", http.StatusInternalServerError)
			return
		}

		jwt, err := middleware.CreateJWT(user.ID, user.Username)
		if err != nil {
			http.Error(w, "Failed to create JWT", http.StatusInternalServerError)
			return
		}
		w.Header().Add("flexusjwt", jwt)

		response, err := json.Marshal(user)
		if err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
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

func (s service) getLoginUser() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var requestBody types.LoginUserRequest

		decoder := json.NewDecoder(r.Body)
		if err := decoder.Decode(&requestBody); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			println(err.Error())
			return
		}

		user, err := s.userAccountStore.GetLoginUser(requestBody.Username, requestBody.Password)
		if err != nil {
			http.Error(w, "Failed to login user", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		jwt, err := middleware.CreateJWT(user.ID, user.Username)
		if err != nil {
			http.Error(w, "Failed to create JWT", http.StatusInternalServerError)
			println(err.Error())
			return
		}
		w.Header().Add("flexusjwt", jwt)

		response, err := json.Marshal(user)
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
