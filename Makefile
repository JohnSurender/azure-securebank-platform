ENV ?= dev
TF_DIR = infra/envs/$(ENV)

.PHONY: help init plan apply destroy fmt lint scan test build up down

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

init: ## terraform init for ENV (dev|staging|prod)
	terraform -chdir=$(TF_DIR) init

plan: ## terraform plan for ENV
	terraform -chdir=$(TF_DIR) plan -out=tfplan

apply: ## terraform apply saved plan for ENV
	terraform -chdir=$(TF_DIR) apply tfplan

destroy: ## terraform destroy ENV (never prod)
	@if [ "$(ENV)" = "prod" ]; then echo "Refusing to destroy prod"; exit 1; fi
	terraform -chdir=$(TF_DIR) destroy

fmt: ## Format all Terraform
	terraform fmt -recursive infra

lint: ## tflint all modules
	tflint --recursive

scan: ## Security scan IaC + containers
	checkov -d infra --quiet
	trivy fs --severity HIGH,CRITICAL .

test: ## Run service unit tests
	cd apps/accounts-service && pip install -q -r requirements.txt && pytest -q
	cd apps/transactions-service && pip install -q -r requirements.txt && pytest -q

up: ## Run the stack locally
	docker compose up --build -d

down: ## Stop local stack
	docker compose down -v
