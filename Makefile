.DEFAULT_GOAL := help
COMPOSE       := docker compose
BACKEND_DIR   := rss_reader_backend
UI_DIR        := rss_reader_ui

# ── Help ──────────────────────────────────────────────────────────────────────

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' | sort

# ── Setup ─────────────────────────────────────────────────────────────────────

.PHONY: setup
setup: ## Create $(BACKEND_DIR)/.env from .env.example (first run only)
	@if [ ! -f $(BACKEND_DIR)/.env ]; then \
		cp $(BACKEND_DIR)/.env.example $(BACKEND_DIR)/.env; \
		echo "Created $(BACKEND_DIR)/.env — fill in GOOGLE_CLIENT_ID/SECRET and JWT_SECRET_KEY."; \
	else \
		echo "$(BACKEND_DIR)/.env already exists — leaving it alone."; \
	fi

# ── Full stack (Docker Compose) ───────────────────────────────────────────────

.PHONY: up
up: ## Build and start the whole stack (postgres, redis, rabbitmq, api, worker, beat, ui)
	$(COMPOSE) up --build

.PHONY: up-d
up-d: ## Build and start the whole stack in the background
	$(COMPOSE) up --build -d

.PHONY: up-prod
up-prod: ## Start the stack with the production-like nginx UI (http://localhost:3000)
	$(COMPOSE) --profile prod up --build -d

.PHONY: down
down: ## Stop and remove the stack (keeps data volumes)
	$(COMPOSE) down

.PHONY: down-v
down-v: ## Stop the stack and delete its data volumes (postgres/redis/rabbitmq)
	$(COMPOSE) down -v

.PHONY: build
build: ## Rebuild all images without starting anything
	$(COMPOSE) build

.PHONY: ps
ps: ## Show stack container status
	$(COMPOSE) ps

.PHONY: logs
logs: ## Tail logs from every service
	$(COMPOSE) logs -f

.PHONY: logs-api
logs-api: ## Tail backend API logs
	$(COMPOSE) logs -f api

.PHONY: logs-ui
logs-ui: ## Tail UI dev-server logs
	$(COMPOSE) logs -f ui

.PHONY: logs-worker
logs-worker: ## Tail Celery worker and beat logs
	$(COMPOSE) logs -f celery-worker celery-beat

# ── Everyday helpers ──────────────────────────────────────────────────────────

.PHONY: health
health: ## Check the API and UI are responding
	curl -sf http://localhost:8080/health | python3 -m json.tool
	curl -sf -o /dev/null http://localhost:5173 && echo "UI OK: http://localhost:5173"

.PHONY: db-shell
db-shell: ## Open a psql shell on the stack Postgres
	$(COMPOSE) exec postgres psql -U postgres -d rss_reader

.PHONY: api-shell
api-shell: ## Open a shell inside the running API container
	$(COMPOSE) exec api bash

.PHONY: seed
seed: ## Seed curated collections (runs inside the API container's network)
	$(COMPOSE) run --rm api python scripts/seed_upsc_collections.py

# ── Local (non-Docker) checks ─────────────────────────────────────────────────

.PHONY: test-backend
test-backend: ## Run the backend test suite locally (needs Postgres + Redis, e.g. `make up-d`)
	$(MAKE) -C $(BACKEND_DIR) test

.PHONY: build-ui
build-ui: ## Typecheck + production-build the UI locally
	npm --prefix $(UI_DIR) ci && npm --prefix $(UI_DIR) run build
