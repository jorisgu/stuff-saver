.PHONY: install
install: ## Install the environment and install the pre-commit hooks
	@echo "🚀 Creating virtual environment using PDM"
	@pdm install
	@pdm run pre-commit install

.PHONY: check
check: ## Run code quality tools.
	@echo "🚀 Checking pdm lock file consistency with 'pyproject.toml': Running pdm lock --check"
	@pdm lock --check
	@echo "🚀 Linting code: Running pre-commit"
	@pdm run pre-commit run -a
	@echo "🚀 Linting with ruff"
	@pdm run ruff check tests stuff_saver --config pyproject.toml
	@echo "🚀 Static type checking: Running mypy"
	@pdm run mypy
	@echo "🚀 Checking for obsolete dependencies: Running deptry"
	@pdm run deptry . --config pyproject.toml

.PHONY: test
test: ## Test the code with pytest
	@echo "🚀 Testing code: Running pytest"
	@pdm run pytest --cov --cov-config=pyproject.toml --cov-report=xml

.PHONY: build
build: clean-build ## Build wheel file
	@echo "🚀 Creating wheel file"
	@pdm build

.PHONY: clean-build
clean-build: ## clean build artifacts
	@rm -rf dist

# .PHONY: publish
# publish: ## publish a release to pypi.
# 	@echo "🚀 Publishing."
# 	@pdm publish --username __token__ --password $PYPI_TOKEN


# .PHONY: build-and-publish
# build-and-publish: build publish ## Build and publish.

.PHONY: release
release: clean-build ## Release a new version
	@echo "🚀 Releasing a new version"
	@pdm run python tasks/release.py
	@echo "Run 'gh release create'"

.PHONY: docs-test
docs-test: ## Test if documentation can be built without warnings or errors
	@pdm run mkdocs build -s

.PHONY: docs-release
docs-release: ## Build and release the documentation
	@pdm run mkdocs gh-deploy --force

.PHONY: docs
docs: ## Build and serve the documentation
	@pdm run mkdocs serve

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
