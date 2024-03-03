package report

import (
	"encoding/json"
	"flexus/internal/types"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type ReportStore interface {
	CreateReport(report types.Report) error
}

type service struct {
	handler     http.Handler
	reportStore ReportStore
}

func NewService(reportStore ReportStore) http.Handler {
	r := chi.NewRouter()
	s := service{
		handler:     r,
		reportStore: reportStore,
	}

	r.Post("/", s.createReport())

	return s
}

func (s service) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.handler.ServeHTTP(w, r)
}

func (s service) createReport() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := r.Context().Value(types.RequestorContextKey).(types.Claims)
		if !ok {
			http.Error(w, "Invalid requestor ID", http.StatusInternalServerError)
			return
		}

		var requestBody types.Report

		decoder := json.NewDecoder(r.Body)
		if err := decoder.Decode(&requestBody); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			println(err.Error())
			return
		}

		requestBody.ReporterID = claims.UserAccountID

		if requestBody.ReportedID <= 0 {
			http.Error(w, "ReportedID can not be null", http.StatusBadRequest)
			return
		}

		if *requestBody.Message == "" {
			requestBody.Message = nil
		}

		err := s.reportStore.CreateReport(requestBody)
		if err != nil {
			http.Error(w, "Failed to create User", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
	}
}
