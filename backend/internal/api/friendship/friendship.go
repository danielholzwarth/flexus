package friendship

import (
	"flexus/internal/types"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type FriendshipStore interface {
	CreateFriendship(friendship types.Friendship) error
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
		requestedUserAccountIDInt, err := strconv.Atoi(requestedUserAccountIDValue)
		if err != nil || requestedUserAccountIDInt <= 0 {
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte("Wrong input for requestedUserAccountIDInt. Must be integer greater than 0."))
			println(err.Error())
			return
		}
		requestedUserAccountID := types.UserAccountID(requestedUserAccountIDInt)

		friendship.RequestorID = claims.UserAccountID
		friendship.RequestedID = requestedUserAccountID
		friendship.IsAccepted = false

		err = s.friendshipStore.CreateFriendship(friendship)
		if err != nil {
			http.Error(w, "Failed to create User", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
	}
}
