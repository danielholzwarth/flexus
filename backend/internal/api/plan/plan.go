package plan

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type PlanStore interface {
	CreatePlan(createPlan types.CreatePlan) error
	GetPlansByUserID(userID int) ([]types.Plan, error)
}

type service struct {
	handler   http.Handler
	planStore PlanStore
}

func NewService(planStore PlanStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:   r,
		planStore: planStore,
	}

	r.Post("/", s.createPlan())
	r.Get("/", s.getPlans())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) createPlan() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		var requestBody types.CreatePlan

		decoder := json.NewDecoder(r.Body)
		if err := decoder.Decode(&requestBody); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			println(err.Error())
			return
		}

		requestBody.UserAccountID = claims.UserAccountID

		err := s.planStore.CreatePlan(requestBody)
		if err != nil {
			http.Error(w, "Failed to create User", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
	}
}

func (s service) getPlans() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		plans, err := s.planStore.GetPlansByUserID(claims.UserAccountID)
		if err != nil {
			http.Error(w, "Failed to create User", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		response, err := json.Marshal(plans)
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
