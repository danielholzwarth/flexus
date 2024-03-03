package best_lifts

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type BestLiftsStore interface {
	GetBestLifts(userAccountID types.UserAccountID) ([]types.BestLiftOverview, error)
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

	r.Get("/{userAccountID}", s.getBestLifts())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) getBestLifts() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		_, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
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

		bestLiftsOverview, err := s.bestLiftsStore.GetBestLifts(userAccountID)
		if err != nil {
			http.Error(w, "Failed to get bestLiftsOverview", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(bestLiftsOverview)
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
