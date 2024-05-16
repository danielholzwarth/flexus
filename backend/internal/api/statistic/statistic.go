package statistic

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type StatisticStore interface {
	GetTotalMovedWeight(userAccountID int, period int) (any, error)
	GetTotalReps(userAccountID int, period int) (any, error)
	GetWorkoutDays(userAccountID int, period int) (any, error)
	GetWorkoutDuration(userAccountID int, period int) (any, error)
}

type service struct {
	handler        http.Handler
	statisticStore StatisticStore
}

func NewService(statisticStore StatisticStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:        r,
		statisticStore: statisticStore,
	}

	r.Get("/total-moved-weight", s.getTotalMovedWeight())
	r.Get("/total-reps", s.getTotalReps())
	r.Get("/workout-days", s.getWorkoutDays())
	r.Get("/workout-duration", s.getWorkoutDuration())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) getTotalMovedWeight() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		periodStr := r.URL.Query().Get("period")
		periodInt64, err := strconv.ParseInt(periodStr, 0, 20)
		if err != nil {
			http.Error(w, "Invalid period", http.StatusBadRequest)
			return
		}
		period := int(periodInt64)

		statisticOverviews, err := s.statisticStore.GetTotalMovedWeight(claims.UserAccountID, period)
		if err != nil {
			http.Error(w, "Failed to get statisticOverview", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(statisticOverviews)
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

func (s service) getTotalReps() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		periodStr := r.URL.Query().Get("period")
		periodInt64, err := strconv.ParseInt(periodStr, 0, 20)
		if err != nil {
			http.Error(w, "Invalid period", http.StatusBadRequest)
			return
		}
		period := int(periodInt64)

		statisticOverviews, err := s.statisticStore.GetTotalReps(claims.UserAccountID, period)
		if err != nil {
			http.Error(w, "Failed to get statisticOverview", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(statisticOverviews)
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

func (s service) getWorkoutDays() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		periodStr := r.URL.Query().Get("period")
		periodInt64, err := strconv.ParseInt(periodStr, 0, 20)
		if err != nil {
			http.Error(w, "Invalid period", http.StatusBadRequest)
			return
		}
		period := int(periodInt64)

		statisticOverviews, err := s.statisticStore.GetWorkoutDays(claims.UserAccountID, period)
		if err != nil {
			http.Error(w, "Failed to get statisticOverview", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(statisticOverviews)
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

func (s service) getWorkoutDuration() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		periodStr := r.URL.Query().Get("period")
		periodInt64, err := strconv.ParseInt(periodStr, 0, 20)
		if err != nil {
			http.Error(w, "Invalid period", http.StatusBadRequest)
			return
		}
		period := int(periodInt64)

		statisticOverviews, err := s.statisticStore.GetWorkoutDuration(claims.UserAccountID, period)
		if err != nil {
			http.Error(w, "Failed to get statisticOverview", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(statisticOverviews)
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
