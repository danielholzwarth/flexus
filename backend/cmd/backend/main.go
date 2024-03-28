package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"

	"flexus/api"
	"flexus/internal/api/best_lifts"
	"flexus/internal/api/exercise"
	"flexus/internal/api/friendship"
	"flexus/internal/api/gym"
	"flexus/internal/api/login_user_account"
	flexusMiddleware "flexus/internal/api/middleware"
	"flexus/internal/api/report"
	"flexus/internal/api/user_account"
	"flexus/internal/api/user_account_gym"
	"flexus/internal/api/user_list"
	"flexus/internal/api/user_settings"
	"flexus/internal/api/workout"
	"flexus/internal/pkg/storage/postgres"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
)

var commitHash string
var databaseDSN = "postgres://postgres:postgres@localhost/postgres?sslmode=disable&connect_timeout=3"

func main() {
	log.Printf("Starting Backend %s\n", commitHash)

	if err := run(); err != nil {
		log.Println(err)
	}

}

func run() error {
	var dsn = os.Getenv("FLEXUS_DATABASE_DSN")
	if dsn != "" {
		databaseDSN = dsn
	}

	r := chi.NewRouter()

	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"*"},
		AllowedHeaders:   []string{"*"},
		AllowCredentials: false,
	}))

	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/docs", http.StatusFound)
	})

	docsPath := "/docs"
	openAPIPath := docsPath + "/swagger.yaml"
	r.Handle(docsPath, api.SwaggerUIHandler(api.SwaggerUIOpts{
		Path:    docsPath,
		SpecURL: openAPIPath,
		Title:   "Flexus",
	}))
	r.Get(openAPIPath, api.SwaggerSpecsHandlerFunc())

	db, err := postgres.New(databaseDSN)
	if err != nil {
		return fmt.Errorf("connecting to postgres: %w", err)
	}

	r.Mount("/login_user_accounts", login_user_account.NewService(db))
	r.Mount("/user_settings", flexusMiddleware.ValidateJWT(user_settings.NewService(db)))
	r.Mount("/workouts", flexusMiddleware.ValidateJWT(workout.NewService(db)))
	r.Mount("/user_accounts", flexusMiddleware.ValidateJWT(user_account.NewService(db)))
	r.Mount("/best_lifts", flexusMiddleware.ValidateJWT(best_lifts.NewService(db)))
	r.Mount("/reports", flexusMiddleware.ValidateJWT(report.NewService(db)))
	r.Mount("/friendships", flexusMiddleware.ValidateJWT(friendship.NewService(db)))
	r.Mount("/gyms", flexusMiddleware.ValidateJWT(gym.NewService(db)))
	r.Mount("/user_account_gym", flexusMiddleware.ValidateJWT(user_account_gym.NewService(db)))
	r.Mount("/user_lists", flexusMiddleware.ValidateJWT(user_list.NewService(db)))
	r.Mount("/exercises", flexusMiddleware.ValidateJWT(exercise.NewService(db)))

	srv := &http.Server{
		Addr:    ":8080",
		Handler: r,
	}

	srvErrChan := make(chan error, 1)
	go func() {
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			srvErrChan <- err
		}
	}()

	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, os.Interrupt)
	select {
	case err := <-srvErrChan:
		return err
	case sig := <-signalChan:
		log.Printf("received %s\n", sig)
	}

	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		return fmt.Errorf("shutting down server: %w", err)
	}
	return nil
}
