package friendship

import (
	"encoding/json"
	"flexus/internal/types"
	"io"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type FriendshipStore interface {
	CreateFriendship(friendship types.Friendship) error
	GetFriendshipFromUserID(requestorID int, requestedID int) (*types.Friendship, error)
	PatchFriendship(requestorID int, requestedID int, columnName string, value any) error
	DeleteFriendship(requestorID int, requestedID int) error
}

type service struct {
	handler         http.Handler
	friendshipStore FriendshipStore
}

func NewService(friendshipStore FriendshipStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:         r,
		friendshipStore: friendshipStore,
	}

	r.Post("/{userAccountID}", s.createFriendship())
	r.Get("/{userAccountID}", s.getFriendshipFromUserID())
	r.Patch("/{userAccountID}", s.patchFriendship())
	r.Delete("/{userAccountID}", s.deleteFriendship())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) createFriendship() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var friendship types.Friendship

		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		requestedUserAccountIDValue := chi.URLParam(r, "userAccountID")
		requestedUserAccountID, err := strconv.Atoi(requestedUserAccountIDValue)
		if err != nil || requestedUserAccountID <= 0 {
			http.Error(w, "Wrong input for requestedUserAccountID. Must be integer greater than 0.", http.StatusBadRequest)
			println(err.Error())
			return
		}

		friendship.RequestorID = claims.UserAccountID
		friendship.RequestedID = requestedUserAccountID
		friendship.IsAccepted = false

		err = s.friendshipStore.CreateFriendship(friendship)
		if err != nil {
			http.Error(w, "Failed to create Friendship", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
	}
}

func (s service) getFriendshipFromUserID() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		requestedUserAccountIDValue := chi.URLParam(r, "userAccountID")
		requestedUserAccountID, err := strconv.Atoi(requestedUserAccountIDValue)
		if err != nil || requestedUserAccountID <= 0 {
			http.Error(w, "Wrong input for requestedUserAccountID. Must be integer greater than 0.", http.StatusBadRequest)
			println(err.Error())
			return
		}

		friendship, err := s.friendshipStore.GetFriendshipFromUserID(claims.UserAccountID, requestedUserAccountID)
		if err != nil {
			http.Error(w, "Failed to get Friendship", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(friendship)
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

func (s service) patchFriendship() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		requestedUserAccountIDValue := chi.URLParam(r, "userAccountID")
		requestedUserAccountID, err := strconv.Atoi(requestedUserAccountIDValue)
		if err != nil || requestedUserAccountID <= 0 {
			http.Error(w, "Wrong input for requestedUserAccountIDInt. Must be integer greater than 0.", http.StatusBadRequest)
			println(err.Error())
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

		if isAccepted, ok := requestBody["isAccepted"].(bool); ok {
			err := s.friendshipStore.PatchFriendship(claims.UserAccountID, requestedUserAccountID, "is_accepted", isAccepted)
			if err != nil {
				http.Error(w, "Failed to patch Friendship", http.StatusInternalServerError)
				println(err.Error())
				return
			}
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}

func (s service) deleteFriendship() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		requestedUserAccountIDValue := chi.URLParam(r, "userAccountID")
		requestedUserAccountID, err := strconv.Atoi(requestedUserAccountIDValue)
		if err != nil || requestedUserAccountID <= 0 {
			http.Error(w, "Wrong input for requestedUserAccountID. Must be integer greater than 0.", http.StatusBadRequest)
			println(err.Error())
			return
		}

		err = s.friendshipStore.DeleteFriendship(claims.UserAccountID, requestedUserAccountID)
		if err != nil {
			http.Error(w, "Failed to delete Friendship", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}
