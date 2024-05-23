.PHONY:backend

backend:
	cd backend/cmd/backend && SET JWT_KEY=secret && go run .