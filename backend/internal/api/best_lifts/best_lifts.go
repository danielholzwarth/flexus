package best_lifts

import (
	"encoding/json"
	parser "flexus/internal/api"
	"flexus/internal/types"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type BestLiftsStore interface {
	PostBestLift(userAccountID int, exerciseID int, position int) ([]types.BestLiftOverview, error)
	PatchBestLift(userAccountID int, exerciseID int, position int) ([]types.BestLiftOverview, error)
	GetBestLiftsFromUserID(userAccountID int) ([]types.BestLiftOverview, error)
}

type service struct {
	handler        http.Handler
	bestLiftsStore BestLiftsStore
}

func NewService(bestLiftsStore BestLiftsStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:        r,
		bestLiftsStore: bestLiftsStore,
	}

	r.Post("/", s.postBestLift())
	r.Patch("/", s.patchBestLift())
	r.Get("/{userAccountID}", s.getBestLiftsFromUserID())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) postBestLift() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		bodyData, err := parser.ParseRequestBody(r, map[string]string{"exerciseID": "int", "position": "int"})
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			println(err.Error())
			return
		}
		exerciseID := bodyData["exerciseID"].(int)
		position := bodyData["position"].(int)

		data, err := s.bestLiftsStore.PostBestLift(claims.UserAccountID, exerciseID, position)
		if err != nil {
			http.Error(w, "Failed to create BestLift", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		if data != nil {
			response, err := json.Marshal(data)
			if err != nil {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				println(err.Error())
				return
			}

			w.Write(response)
			w.WriteHeader(http.StatusCreated)
		}
	}
}

func (s service) patchBestLift() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		bodyData, err := parser.ParseRequestBody(r, map[string]string{"exerciseID": "int", "position": "int"})
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			println(err.Error())
			return
		}
		exerciseID := bodyData["exerciseID"].(int)
		position := bodyData["position"].(int)

		data, err := s.bestLiftsStore.PatchBestLift(claims.UserAccountID, exerciseID, position)
		if err != nil {
			http.Error(w, "Failed to create BestLift", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		if data != nil {
			response, err := json.Marshal(data)
			if err != nil {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				println(err.Error())
				return
			}

			w.Write(response)
		}
	}
}

func (s service) getBestLiftsFromUserID() http.HandlerFunc {
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

		data, err := s.bestLiftsStore.GetBestLiftsFromUserID(userAccountID)
		if err != nil {
			http.Error(w, "Failed to get bestLiftsOverview", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		if data != nil {
			response, err := json.Marshal(data)
			if err != nil {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				println(err.Error())
				return
			}

			w.Write(response)
		}
		w.WriteHeader(http.StatusOK)
	}
}
