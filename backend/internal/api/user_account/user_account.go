package user_account

import (
	"encoding/base64"
	"encoding/json"
	"flexus/internal/types"
	"io"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"golang.org/x/crypto/bcrypt"
)

type UserAccountStore interface {
	GetUserAccountInformation(userAccountID int) (types.UserAccountInformation, error)
	PatchUserAccount(columnName string, value any, userAccountID int) error
	GetUsernameAvailability(username string) (bool, error)
	DeleteUserAccount(userAccountID int) error
	ValidatePasswordByID(userAccountID int, password string) error
	GetUserAccountInformations(userAccountID int, params map[string]any) ([]any, error)
	PatchEntireUserAccount(userAccountID int, userAccount types.UserAccount) error
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
	r.Patch("/", s.patchUserAccount())
	r.Delete("/", s.deleteUserAccount())
	r.Get("/", s.getUserAccountInformations())
	r.Patch("/sync", s.patchEntireUserAccount())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) getUserAccountInformation() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		_, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		userAccountIDValue := chi.URLParam(r, "userAccountID")
		userAccountID, err := strconv.Atoi(userAccountIDValue)
		if err != nil || userAccountID <= 0 {
			http.Error(w, "Wrong input for userAccountID. Must be integer greater than 0.", http.StatusBadRequest)
			println(err.Error())
			return
		}

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

func (s service) patchUserAccount() http.HandlerFunc {
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

		if username, ok := requestBody["username"].(string); ok {
			availability, err := s.userAccountStore.GetUsernameAvailability(username)
			if err != nil {
				http.Error(w, "Failed to get username availability", http.StatusInternalServerError)
				println(err.Error())
				return
			}

			if !availability {
				http.Error(w, "Username is already assigned", http.StatusBadRequest)
				println("Username is already assigned")
				return
			}

			err = s.userAccountStore.PatchUserAccount("username", username, claims.UserAccountID)
			if err != nil {
				http.Error(w, "Failed to patch username", http.StatusInternalServerError)
				println(err.Error())
				return
			}
		}

		if name, ok := requestBody["name"].(string); ok {
			err := s.userAccountStore.PatchUserAccount("name", name, claims.UserAccountID)
			if err != nil {
				http.Error(w, "Failed to patch name", http.StatusInternalServerError)
				println(err.Error())
				return
			}
		}

		if oldPassword, ok := requestBody["old_password"].(string); ok {
			err = s.userAccountStore.ValidatePasswordByID(claims.UserAccountID, oldPassword)
			if err != nil {
				http.Error(w, "Failed to validate password", http.StatusBadRequest)
				println(err.Error())
				return
			}

			if newPassword, ok := requestBody["new_password"].(string); ok {
				hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
				if err != nil {
					http.Error(w, "Failed to hash password", http.StatusInternalServerError)
					println(err.Error())
					return
				}
				err = s.userAccountStore.PatchUserAccount("password", hashedPassword, claims.UserAccountID)
				if err != nil {
					http.Error(w, "Failed to patch new password", http.StatusInternalServerError)
					println(err.Error())
					return
				}
			}
		}

		if profilePicture, ok := requestBody["profile_picture"].(string); ok {
			if profilePicture != "" {
				imageBytes, err := base64.StdEncoding.DecodeString(profilePicture)
				if err != nil {
					http.Error(w, "Failed to decode profilePicture", http.StatusBadRequest)
					println(err.Error())
					return
				}

				err = s.userAccountStore.PatchUserAccount("profile_picture", imageBytes, claims.UserAccountID)
				if err != nil {
					http.Error(w, "Failed to patch profilePicture", http.StatusInternalServerError)
					println(err.Error())
					return
				}
			} else {
				err := s.userAccountStore.PatchUserAccount("profile_picture", nil, claims.UserAccountID)
				if err != nil {
					http.Error(w, "Failed to patch profilePicture", http.StatusInternalServerError)
					println(err.Error())
					return
				}
			}
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}

func (s service) deleteUserAccount() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		err := s.userAccountStore.DeleteUserAccount(claims.UserAccountID)
		if err != nil {
			http.Error(w, "Failed to get userAccountOverview", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}

func (s service) getUserAccountInformations() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		params := make(map[string]any)
		query := r.URL.Query()

		if v := query.Get("isFriend"); v != "" {
			b, err := strconv.ParseBool(v)
			if err != nil {
				println(err.Error())
			} else {
				params["isFriend"] = b
			}
		}

		if v := query.Get("hasRequest"); v != "" {
			b, err := strconv.ParseBool(v)
			if err != nil {
				println(err.Error())
			} else {
				params["hasRequest"] = b
			}
		}

		params["keyword"] = query.Get("keyword")

		if v := query.Get("gymID"); v != "" {
			id, err := strconv.Atoi(v)
			if err != nil || id <= 0 {
				println(err.Error())
			} else {
				params["gymID"] = id
			}
		}

		if v := query.Get("isWorkingOut"); v != "" {
			b, err := strconv.ParseBool(v)
			if err != nil {
				println(err.Error())
			} else {
				params["isWorkingOut"] = b
			}
		}

		informations, err := s.userAccountStore.GetUserAccountInformations(claims.UserAccountID, params)
		if err != nil {
			http.Error(w, "Failed to get UserInformation", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(informations)
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

func (s service) patchEntireUserAccount() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		var requestBody types.UserAccount

		decoder := json.NewDecoder(r.Body)
		if err := decoder.Decode(&requestBody); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			println(err.Error())
			return
		}

		if requestBody.Name == "" {
			http.Error(w, "Name can not be empty", http.StatusBadRequest)
			println("Name can not be empty")
			return
		}

		if requestBody.Username == "" {
			http.Error(w, "Username can not be empty", http.StatusBadRequest)
			println("Username can not be empty")
			return
		}

		if requestBody.Level <= 0 {
			http.Error(w, "Level must be greater than 0", http.StatusBadRequest)
			println("Level must be greater than 0")
			return
		}

		err := s.userAccountStore.PatchEntireUserAccount(claims.UserAccountID, requestBody)
		if err != nil {
			http.Error(w, "Patching entire userAccount failed", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}
