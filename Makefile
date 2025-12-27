.PHONY: help install test lint format run-fastapi-example run-multi-provider-example docs docs-serve build publish publish-test bump-patch bump-minor bump-major tag release

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

install: ## Install the package in development mode
	pip install -e .[dev]

test: ## Run tests
	pytest

lint: ## Run linter
	ruff check src/

format: ## Format code
	ruff format src/

run-fastapi-example: ## Run the FastAPI example
	python examples/fastapi_app.py

run-multi-provider-example: ## Run the multi-provider example
	python examples/multi_provider_app.py

docs: ## Build documentation
	pip install -e .[docs]
	sphinx-build -b html docs docs/_build/html

docs-serve: ## Serve documentation locally
	cd docs/_build/html && python -m http.server 8000

build: ## Build distribution packages
	pip install build
	python -m build

publish-test: build ## Publish to TestPyPI
	pip install twine
	python -m twine upload --repository testpypi dist/*

publish: build ## Publish to PyPI
	pip install twine
	python -m twine upload dist/*

bump-patch: ## Bump patch version (e.g., 0.1.0 -> 0.1.1)
	@CURRENT_VERSION=$$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/' | head -1) && \
	MAJOR=$$(echo $$CURRENT_VERSION | cut -d. -f1) && \
	MINOR=$$(echo $$CURRENT_VERSION | cut -d. -f2) && \
	PATCH=$$(echo $$CURRENT_VERSION | cut -d. -f3) && \
	NEW_PATCH=$$(echo $$PATCH + 1 | bc) && \
	NEW_VERSION="$$MAJOR.$$MINOR.$$NEW_PATCH" && \
	echo "Current version: $$CURRENT_VERSION" && \
	sed -i.bak '/^\[project\]/,/^version = / { s/version = ".*"/version = "'"$$NEW_VERSION"'"/; }' pyproject.toml && \
	rm pyproject.toml.bak && \
	echo "New version: $$NEW_VERSION"

bump-minor: ## Bump minor version (e.g., 0.1.0 -> 0.2.0)
	@CURRENT_VERSION=$$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/' | head -1) && \
	MAJOR=$$(echo $$CURRENT_VERSION | cut -d. -f1) && \
	MINOR=$$(echo $$CURRENT_VERSION | cut -d. -f2) && \
	NEW_MINOR=$$(echo $$MINOR + 1 | bc) && \
	NEW_VERSION="$$MAJOR.$$NEW_MINOR.0" && \
	echo "Current version: $$CURRENT_VERSION" && \
	sed -i.bak '/^\[project\]/,/^version = / { s/version = ".*"/version = "'"$$NEW_VERSION"'"/; }' pyproject.toml && \
	rm pyproject.toml.bak && \
	echo "New version: $$NEW_VERSION"

bump-major: ## Bump major version (e.g., 0.1.0 -> 1.0.0)
	@CURRENT_VERSION=$$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/' | head -1) && \
	MAJOR=$$(echo $$CURRENT_VERSION | cut -d. -f1) && \
	NEW_MAJOR=$$(echo $$MAJOR + 1 | bc) && \
	NEW_VERSION="$$NEW_MAJOR.0.0" && \
	echo "Current version: $$CURRENT_VERSION" && \
	sed -i.bak '/^\[project\]/,/^version = / { s/version = ".*"/version = "'"$$NEW_VERSION"'"/; }' pyproject.toml && \
	rm pyproject.toml.bak && \
	echo "New version: $$NEW_VERSION"

tag: ## Create git tag with current version
	@VERSION=$$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/') && \
	echo "Creating tag v$$VERSION" && \
	git tag -a "v$$VERSION" -m "Release v$$VERSION" && \
	echo "Tag v$$VERSION created"

release: bump-patch tag ## Bump patch version and create git tag