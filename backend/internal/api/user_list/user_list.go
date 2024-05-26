package user_list

import (
	"encoding/json"
	parser "flexus/internal/api"
	"flexus/internal/types"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type UserListStore interface {
	PostUserList(userAccountID int, columnName string) (int, error)
	GetHasUserList(userAccountID int, listID int, userID int) (bool, error)
	PatchUserList(userAccountID int, listID int, userID int) error
	GetUserListFromListID(userAccountID int, listID int) ([]int, error)
}

type service struct {
	handler       http.Handler
	userListStore UserListStore
}

func NewService(userListStore UserListStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:       r,
		userListStore: userListStore,
	}

	r.Post("/", s.postUserList())
	r.Get("/", s.getHasUserList())
	r.Patch("/", s.patchUserList())
	r.Get("/{listID}", s.getUserListFromListID())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) postUserList() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		bodyData, err := parser.ParseRequestBody(r, map[string]string{"columnName": "string"})
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			println(err.Error())
			return
		}
		columnName := bodyData["columnName"].(string)

		userList, err := s.userListStore.PostUserList(claims.UserAccountID, columnName)
		if err != nil {
			http.Error(w, "Failed to post Userlist", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(userList)
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

func (s service) getHasUserList() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		bodyData, err := parser.ParseRequestBody(r, map[string]string{"listID": "int", "userID": "int"})
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			println(err.Error())
			return
		}
		listID := bodyData["listID"].(int)
		userID := bodyData["userID"].(int)

		if listID <= 0 {
			http.Error(w, "Wrong input for listID. Must be integer greater than 0.", http.StatusBadRequest)
			println("Wrong input for listID. Must be integer greater than 0.")
			return
		}

		if userID <= 0 {
			http.Error(w, "Wrong input for userID. Must be integer greater than 0.", http.StatusBadRequest)
			println("Wrong input for userID. Must be integer greater than 0.")
			return
		}

		settings, err := s.userListStore.GetHasUserList(claims.UserAccountID, listID, userID)
		if err != nil {
			http.Error(w, "Failed to get availability", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(settings)
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

func (s service) patchUserList() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		bodyData, err := parser.ParseRequestBody(r, map[string]string{"listID": "int", "userID": "int"})
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			println(err.Error())
			return
		}
		listID := bodyData["listID"].(int)
		userID := bodyData["userID"].(int)

		if listID <= 0 {
			http.Error(w, "Wrong input for listID. Must be integer greater than 0.", http.StatusBadRequest)
			println("Wrong input for listID. Must be integer greater than 0.")
			return
		}

		if userID <= 0 {
			http.Error(w, "Wrong input for userID. Must be integer greater than 0.", http.StatusBadRequest)
			println("Wrong input for userID. Must be integer greater than 0.")
			return
		}

		err = s.userListStore.PatchUserList(claims.UserAccountID, listID, userID)
		if err != nil {
			http.Error(w, "Failed to patch isNotifyEveryone", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}

func (s service) getUserListFromListID() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		listIDValue := chi.URLParam(r, "listID")
		listID, err := strconv.Atoi(listIDValue)
		if err != nil || listID <= 0 {
			http.Error(w, "Wrong input for listID. Must be integer greater than 0.", http.StatusBadRequest)
			println(err.Error())
			return
		}

		settings, err := s.userListStore.GetUserListFromListID(claims.UserAccountID, listID)
		if err != nil {
			http.Error(w, "Failed to get availability", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(settings)
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
