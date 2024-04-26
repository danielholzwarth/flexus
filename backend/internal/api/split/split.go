package splits

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type SplitsStore interface {
	GetSplitsFromPlanID(userAccountID int, planID int) ([]types.Split, error)
}

type service struct {
	handler        http.Handler
	splitsStore SplitsStore
}

func NewService(splitsStore SplitsStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:        r,
		splitsStore: splitsStore,
	}

	r.Get("/{planID}", s.getSplits())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) getSplits() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		planIDValue := chi.URLParam(r, "planID")
		planID, err := strconv.Atoi(planIDValue)
		if err != nil || planID <= 0 {
			http.Error(w, "Wrong input for planID. Must be integer greater than 0.", http.StatusBadRequest)
			println(err.Error())
			return
		}

		bestLiftsOverview, err := s.splitsStore.GetSplitsFromPlanID(claims.UserAccountID, planID)
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
