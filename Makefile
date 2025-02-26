.ONESHELL:
SHELL := /bin/bash

.SILENT:

%:
	@:

export PYTHONPATH=.


DEFAULT_GOAL := help
.PHONY: help
help:
	awk 'BEGIN {FS = ":.*?## "} /^[%a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: install
install: ## Create poetry environment and install all dependencies.
	poetry config virtualenvs.in-project true --local
	poetry env use 3.11
	poetry install

.PHONY: style-check
style-check: ## Run style checks.
	printf "Style Checking with Ruff\n"
	poetry run ruff check .

.PHONY: restyle
restyle: ## Reformat code with Ruff and Black.
	poetry run ruff format .
	poetry run ruff check . --fix .

.PHONY: static-check
static-check: ## Run strict typing checks.
	printf "Static Checking with Mypy\n"
	poetry run mypy .

.PHONY: tests
tests: ## Run tests.
	printf "Tests with Pytest\n"
ifeq (plain, $(filter plain,$(MAKECMDGOALS)))
	pytest tests -s
else
	poetry run pytest -s
endif

.PHONY: battery
battery: style-check static-check tests ## Run all checks and tests
	printf "\nPassed all checks and tests...\n"

.PHONY: requirements
requirements: ## Generate requirements.txt based on poetry env.
	poetry export -f requirements.txt --output requirements.txt --without-hashes --with dev

.PHONY: run.training
run.training: ## Run training pipeline with dev configuration.
ifeq (plain, $(filter plain,$(MAKECMDGOALS)))
	python -m conversion_predictor.__main__ training
else
	poetry run python -m conversion_predictor.__main__ training
endif

.PHONY: run.inference
run.inference: ## Run inference pipeline with dev configuration.
ifeq (plain, $(filter plain,$(MAKECMDGOALS)))
	python -m conversion_predictor.__main__ inference
else
	poetry run python -m conversion_predictor.__main__ inference
endif