package plan

import (
	"encoding/json"
	"flexus/internal/types"
	"io"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type PlanStore interface {
	CreatePlan(createPlan types.CreatePlan) error
	GetActivePlan(userID int) (types.Plan, error)
	GetPlansByUserID(userID int) ([]types.Plan, error)
	DeletePlan(userID int, planID int) error
	PatchPlan(userID int, planID int, columnName string, value any) (types.Plan, error)
	GetPlanOverview(userID int) (types.PlanOverview, error)
	PatchPlanExercise(userID int, planID int, splitID int, newExerciseID int, oldExerciseID int) (types.Plan, error)
	PatchPlanExercises(userID int, planID int, splitID int, newExercises []int) (types.Plan, error)
	PatchEntirePlans(userAccountID int, plans []types.Plan) error
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
	r.Get("/active", s.getActivePlan())
	r.Get("/", s.getPlans())
	r.Delete("/{planID}", s.deletePlan())
	r.Patch("/{planID}", s.patchPlan())
	r.Get("/overview", s.getPlanOverview())
	r.Patch("/sync", s.patchEntirePlans())

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

func (s service) getActivePlan() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		plan, err := s.planStore.GetActivePlan(claims.UserAccountID)
		if err != nil {
			http.Error(w, "Failed to create User", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		if plan.ID != 0 {
			response, err := json.Marshal(plan)
			if err != nil {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				println(err.Error())
				return
			}
			w.Write(response)

		} else {
			response, err := json.Marshal(nil)
			if err != nil {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				println(err.Error())
				return
			}
			w.Write(response)
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
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

func (s service) deletePlan() http.HandlerFunc {
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

		err = s.planStore.DeletePlan(claims.UserAccountID, planID)
		if err != nil {
			http.Error(w, "Failed to create User", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}

func (s service) patchPlan() http.HandlerFunc {
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

		if isActive, ok := requestBody["isActive"].(bool); ok {
			plan, err := s.planStore.PatchPlan(claims.UserAccountID, planID, "is_active", isActive)
			if err != nil {
				http.Error(w, "Failed to patch plan is active", http.StatusInternalServerError)
				println(err.Error())
				return
			}

			response, err := json.Marshal(plan)
			if err != nil {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				println(err.Error())
				return
			}
			w.Write(response)
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)
		}

		if newExerciseIDFloat, ok := requestBody["newExerciseID"].(float64); ok {
			newExerciseID := int(newExerciseIDFloat)

			var splitID int
			if splitIDFloat, ok := requestBody["splitID"].(float64); !ok {
				w.WriteHeader(http.StatusBadRequest)
				return
			} else {
				splitID = int(splitIDFloat)
			}

			var oldExerciseID int
			if oldExerciseIDFloat, ok := requestBody["oldExerciseID"].(float64); !ok {
				w.WriteHeader(http.StatusBadRequest)
				return
			} else {
				oldExerciseID = int(oldExerciseIDFloat)
			}

			plan, err := s.planStore.PatchPlanExercise(claims.UserAccountID, planID, splitID, newExerciseID, oldExerciseID)
			if err != nil {
				http.Error(w, "Failed to patch plan is active", http.StatusInternalServerError)
				println(err.Error())
				return
			}

			response, err := json.Marshal(plan)
			if err != nil {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				println(err.Error())
				return
			}
			w.Write(response)
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)
		}

		if newExerciseIDsInterfaces, ok := requestBody["newExerciseIDs"].([]interface{}); ok {
			var newExerciseIDs []int
			for _, v := range newExerciseIDsInterfaces {
				if f, ok := v.(float64); ok {
					newExerciseIDs = append(newExerciseIDs, int(f))
				} else {
					w.WriteHeader(http.StatusBadRequest)
					return
				}
			}

			println("updating exercises")

			var splitID int
			if splitIDFloat, ok := requestBody["splitID"].(float64); !ok {
				w.WriteHeader(http.StatusBadRequest)
				return
			} else {
				splitID = int(splitIDFloat)
			}

			plan, err := s.planStore.PatchPlanExercises(claims.UserAccountID, planID, splitID, newExerciseIDs)
			if err != nil {
				http.Error(w, "Failed to patch plan is active", http.StatusInternalServerError)
				println(err.Error())
				return
			}

			response, err := json.Marshal(plan)
			if err != nil {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				println(err.Error())
				return
			}
			w.Write(response)
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
	}
}

func (s service) getPlanOverview() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		planOverview, err := s.planStore.GetPlanOverview(claims.UserAccountID)
		if err != nil {
			http.Error(w, "Failed to get Plan Overview", http.StatusInternalServerError)
			println(err.Error())
			return
		}

		if planOverview.Plan.ID != 0 {
			response, err := json.Marshal(planOverview)
			if err != nil {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				println(err.Error())
				return
			}
			w.Write(response)

		} else {
			response, err := json.Marshal(nil)
			if err != nil {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				println(err.Error())
				return
			}
			w.Write(response)
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}

func (s service) patchEntirePlans() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		var requestBody struct {
			Plans []types.Plan `json:"plans"`
		}

		decoder := json.NewDecoder(r.Body)
		if err := decoder.Decode(&requestBody); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			println(err.Error())
			return
		}

		err := s.planStore.PatchEntirePlans(claims.UserAccountID, requestBody.Plans)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			println(err.Error())
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
	}
}
