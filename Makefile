# 5D-GAI Intensive Course - Makefile
# Helper commands for project management

.PHONY: help setup dev clean lint lint-all lint-py lint-sh lint-org lint-el format format-py format-sh test test-paper-summarizer test-livestream api-test env-test test-genai docker docker-jupyter docker-api install-dev-tools check-tools tangle tangle-all build paper-summaries extract-french-verbs verb-embeddings dépatouiller genai-embeddings verb-similarity verb-matrix

# Colors for terminal output
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
BLUE   := $(shell tput -Txterm setaf 4)
RESET  := $(shell tput -Txterm sgr0)

# Command definitions
PYTHON := poetry run python
HY     := poetry run hy
# Prefer a ruff already on PATH (system or `poetry shell`); fall back to `poetry run`
RUFF   := $(shell command -v ruff 2>/dev/null || echo poetry run ruff)

# Org files and their targets
ORG_FILES := $(shell find . -name "*.org" | grep -v -E '(/\.|/docs/|/node_modules/)')
PY_TARGETS := $(patsubst %.org,%.py,$(ORG_FILES))
HY_TARGETS := $(patsubst %.org,%.hy,$(ORG_FILES))

# Paper files and summary targets
PAPER_FILES := $(shell find papers -name "*.pdf")
SUMMARY_TARGETS := $(patsubst %.pdf,%.summary.txt,$(PAPER_FILES))
PROMPT_TEMPLATE := prompts/summarize-paper.md

# Default target when running 'make'
help:
	@echo "${BLUE}5D-GAI Intensive Course${RESET} - Helper Commands"
	@echo ""
	@echo "${YELLOW}Usage:${RESET}"
	@echo "  ${YELLOW}make${RESET} ${GREEN}<command>${RESET}"
	@echo ""
	@echo "${YELLOW}Available commands:${RESET}"
	@echo "  ${GREEN}help${RESET}           Show this help message"
	@echo "  ${GREEN}setup${RESET}          Setup Python environment with Poetry"
	@echo "  ${GREEN}dev${RESET}            Start Poetry shell for development"
	@echo "  ${GREEN}clean${RESET}          Remove build artifacts and cache files"
	@echo "  ${YELLOW}Linting & Formatting:${RESET}"
	@echo "  ${GREEN}lint${RESET}           Run all linters (Python, Shell, Org, Elisp)"
	@echo "  ${GREEN}lint-py${RESET}        Lint Python files"
	@echo "  ${GREEN}lint-sh${RESET}        Lint shell scripts"
	@echo "  ${GREEN}lint-org${RESET}       Lint Org mode files"
	@echo "  ${GREEN}lint-el${RESET}        Lint Emacs Lisp files"
	@echo "  ${GREEN}format${RESET}         Format all code files"
	@echo "  ${GREEN}format-py${RESET}      Format Python files with black and isort"
	@echo "  ${GREEN}format-sh${RESET}      Format shell scripts with shfmt"
	@echo "  ${YELLOW}Org-mode & Tangling:${RESET}"
	@echo "  ${GREEN}tangle${RESET}         Tangle a specific org file (make tangle FILE=path/to/file.org)"
	@echo "  ${GREEN}tangle-all${RESET}     Tangle all org files in the project"
	@echo "  ${GREEN}build${RESET}          Tangle all org files and build source files"
	@echo "  ${YELLOW}Testing & Docker:${RESET}"
	@echo "  ${GREEN}test${RESET}           Run tests"
	@echo "  ${GREEN}test-paper-summarizer${RESET} Run paper summarizer tests"
	@echo "  ${GREEN}test-livestream${RESET} Run livestream transcriber tests"
	@echo "  ${GREEN}api-test${RESET}       Test API connectivity with Gemini"
	@echo "  ${GREEN}env-test${RESET}       Test environment setup for Google API"
	@echo "  ${GREEN}paper-summaries${RESET} Generate summaries for all papers using Gemini"
	@echo "  ${GREEN}extract-french-verbs${RESET} Extract French verbs for embedding tests"
	@echo "  ${GREEN}verb-embeddings${RESET} Process French verbs for embeddings"
	@echo "  ${GREEN}dépatouiller${RESET} Run embedding debug test with dépatouiller"
	@echo "  ${GREEN}docker${RESET}         Build all Docker containers"
	@echo "  ${GREEN}docker-jupyter${RESET} Run Jupyter notebook server in Docker"
	@echo "  ${GREEN}docker-api${RESET}     Run API service in Docker"
	@echo "  ${YELLOW}Development Tools:${RESET}"
	@echo "  ${GREEN}install-dev-tools${RESET} Install development tools (linters, formatters)"
	@echo "  ${GREEN}check-tools${RESET}     Check if required development tools are installed"
	@echo ""
	@echo "${YELLOW}Examples:${RESET}"
	@echo "  ${YELLOW}make setup${RESET}    # Install project dependencies"
	@echo "  ${YELLOW}make api-test${RESET} # Verify Gemini API connectivity"

# Setup Python environment
setup: check-tools
	@echo "${BLUE}Setting up Python environment with Poetry...${RESET}"
	@if ! command -v poetry > /dev/null; then \
		echo "${YELLOW}Poetry not found. Installing...${RESET}"; \
		curl -sSL https://install.python-poetry.org | python3 -; \
	fi
	@echo "${GREEN}Installing dependencies...${RESET}"
	@poetry install
	@mkdir -p notebooks/{day1,day2,day3,day4,day5}
	@mkdir -p papers/{day1,day2,day3,day4,day5}
	@mkdir -p resources data config
	@if [ ! -f .env ]; then \
		echo "${YELLOW}Creating .env file template...${RESET}"; \
		echo "# API Keys" > .env; \
		echo "AI_STUDIO_API_KEY=\"\"" >> .env; \
		echo "KAGGLE_USERNAME=\"\"" >> .env; \
		echo "KAGGLE_KEY=\"\"" >> .env; \
		echo "OPENAI_API_KEY=\"\"" >> .env; \
		echo "ANTHROPIC_API_KEY=\"\"" >> .env; \
	fi
	@echo "${GREEN}Setup complete! Run 'make dev' to activate the environment.${RESET}"

# Activate Poetry shell for development
dev:
	@echo "${BLUE}Starting Poetry shell...${RESET}"
	@poetry shell

# Clean build artifacts and cache files
clean:
	@echo "${BLUE}Cleaning project...${RESET}"
	@find . -type d -name __pycache__ -exec rm -rf {} +
	@find . -type d -name .pytest_cache -exec rm -rf {} +
	@find . -type d -name .ipynb_checkpoints -exec rm -rf {} +
	@find . -type f -name "*.pyc" -delete
	@find . -type f -name "*.pyo" -delete
	@find . -type f -name "*.pyd" -delete
	@find . -type f -name ".coverage" -delete
	@find . -type d -name "*.egg-info" -exec rm -rf {} +
	@find . -type d -name "*.egg" -exec rm -rf {} +
	@find . -type d -name ".tox" -exec rm -rf {} +
	@find . -type d -name "*.dist-info" -exec rm -rf {} +
	@find . -type d -name "*htmlcov" -exec rm -rf {} +
	@echo "${GREEN}Project cleaned!${RESET}"

# Install development tools
install-dev-tools:
	@echo "${BLUE}Installing development tools...${RESET}"
	@poetry add --group dev black ruff isort flake8 mypy pytest
	@echo "${YELLOW}Please install the following system tools if not already available:${RESET}"
	@echo "  - shellcheck: Shell script static analysis"
	@echo "  - shfmt: Shell script formatter"
	@echo "  - emacs: Required for org-mode operations"
	@echo "${GREEN}Python development tools installed!${RESET}"

# Check required tools
check-tools:
	@echo "${BLUE}Checking required tools...${RESET}"
	@poetry run python -c "import black, ruff, isort" 2>/dev/null || echo "${YELLOW}Missing Python tools. Run 'make install-dev-tools'${RESET}"
	@command -v shellcheck >/dev/null 2>&1 || echo "${YELLOW}Warning: shellcheck not found${RESET}"
	@command -v shfmt >/dev/null 2>&1 || echo "${YELLOW}Warning: shfmt not found${RESET}"
	@command -v emacs >/dev/null 2>&1 || echo "${YELLOW}Warning: emacs not found${RESET}"
	@echo "${GREEN}Tool check complete!${RESET}"
	@touch .tools-checked

# Run all linters
# lint-org and lint-el require a fully provisioned Emacs (melpa packages, gptel)
# and are kept available as standalone targets via `lint-all`.
lint: lint-py lint-sh
	@echo "${GREEN}All linting complete!${RESET}"

# Run all linters using the lint-all.sh script
lint-all:
	@echo "${BLUE}Running comprehensive linting with lint-all.sh...${RESET}"
	@./scripts/lint-all.sh
	@echo "${GREEN}Comprehensive linting complete!${RESET}"

# Lint Python files
# src/ is Hy-only; ruff covers the role of black/isort/flake8 for the few .py files we have
PY_LINT_PATHS := $(shell find src tests examples -name "*.py" 2>/dev/null)
lint-py:
	@echo "${BLUE}Linting Python files...${RESET}"
	@if [ -n "$(PY_LINT_PATHS)" ]; then \
		$(RUFF) check $(PY_LINT_PATHS); \
	else \
		echo "${YELLOW}No .py files to lint${RESET}"; \
	fi
	@echo "${GREEN}Python linting complete!${RESET}"

# Lint shell scripts
SH_LINT_PATHS := $(wildcard scripts/*.sh) $(wildcard *.sh)
lint-sh:
	@echo "${BLUE}Linting shell scripts...${RESET}"
	@if [ -n "$(SH_LINT_PATHS)" ]; then \
		shellcheck $(SH_LINT_PATHS); \
	else \
		echo "${YELLOW}No shell scripts to lint${RESET}"; \
	fi
	@echo "${GREEN}Shell script linting complete!${RESET}"

# Lint Org mode files
lint-org:
	@echo "${BLUE}Linting Org files...${RESET}"
	@emacs --batch --load=.emacs.d/init.el --eval "(require 'org)" \
		--eval "(dolist (file (directory-files-recursively \".\" \"\\.org$$\" t)) \
			(unless (or (string-match-p \"/\\.\" file) (string-match-p \"/node_modules/\" file)) \
				(with-current-buffer (find-file-noselect file) \
					(org-lint))))" \
		--kill
	@echo "${GREEN}Org linting complete!${RESET}"

# Lint Emacs Lisp files
lint-el:
	@echo "${BLUE}Linting Emacs Lisp files...${RESET}"
	@emacs --batch --eval "(dolist (file (directory-files-recursively \".\" \"\\.el$$\" t)) \
		(unless (or (string-match-p \"/\\.\" file) (string-match-p \"/node_modules/\" file)) \
			(byte-compile-file file t)))" \
		--eval "(dolist (file (directory-files \".\" t \"\\.elc$$\")) (delete-file file))"
	@echo "${GREEN}Emacs Lisp linting complete!${RESET}"

# Format all code files
format: format-py format-sh
	@echo "${GREEN}All formatting complete!${RESET}"

# Format Python files
format-py:
	@echo "${BLUE}Formatting Python files...${RESET}"
	@poetry run black src tests examples
	@poetry run isort src tests examples
	@echo "${GREEN}Python formatting complete!${RESET}"

# Format shell scripts
format-sh:
	@echo "${BLUE}Formatting shell scripts...${RESET}"
	@if [ -n "$(SH_LINT_PATHS)" ]; then \
		shfmt -w -s -i 4 $(SH_LINT_PATHS); \
	fi
	@echo "${GREEN}Shell script formatting complete!${RESET}"

# Run tests that don't require external services (live API keys, Ollama, etc.)
# Hy tests use their own (when (= __name__ "__main__")) runner, not pytest.
# `api-test`, `test-genai`, `test-ollama-*`, etc. cover the external-service tests.
test: test-paper-summarizer test-livestream
	@echo "${GREEN}Tests complete!${RESET}"

# Run paper summarizer tests
test-paper-summarizer:
	@echo "${BLUE}Running paper summarizer tests...${RESET}"
	@$(HY) tests/hy/test_paper_summarizer.hy
	@echo "${GREEN}Paper summarizer tests complete!${RESET}"

# Run livestream transcriber tests
test-livestream:
	@echo "${BLUE}Running livestream transcriber tests...${RESET}"
	@$(HY) tests/hy/test_livestream_transcriber.hy
	@echo "${GREEN}Livestream transcriber tests complete!${RESET}"

# Test API connectivity with Gemini
api-test:
	@echo "${BLUE}Testing Gemini API connectivity...${RESET}"
	@$(PYTHON) -c "\
	from src.gemini_client import GeminiClient; \
	import sys; \
	try: \
		client = GeminiClient(); \
		response = client.generate_content('Hello, Gemini! Respond with a short greeting.'); \
		print(f'${GREEN}API Response: ${RESET}' + client.extract_text(response)); \
		print(f'${GREEN}API Test successful!${RESET}'); \
	except Exception as e: \
		print(f'${YELLOW}API Test failed: ${RESET}' + str(e), file=sys.stderr); \
		sys.exit(1);"

# Build Docker containers
docker:
	@echo "${BLUE}Building Docker containers...${RESET}"
	@docker-compose build
	@echo "${GREEN}Docker build complete!${RESET}"

# Run Jupyter notebook server in Docker
docker-jupyter:
	@echo "${BLUE}Starting Jupyter notebook server in Docker...${RESET}"
	@docker-compose up notebook
	@echo "${GREEN}Jupyter notebook server stopped.${RESET}"

# Run API service in Docker
docker-api:
	@echo "${BLUE}Starting API service in Docker...${RESET}"
	@docker-compose up api
	@echo "${GREEN}API service stopped.${RESET}"

# Tangle a specific org file with dependency checking
%.py %.hy: %.org
	@echo "${BLUE}Tangling $<...${RESET}"
	@./scripts/tangle-org.sh $<

# Tangle a specific org file (using the script)
tangle:
	@if [ -z "$(FILE)" ]; then \
		echo "${YELLOW}Error: No file specified. Usage: make tangle FILE=path/to/file.org${RESET}"; \
		exit 1; \
	fi
	@if [ ! -f "$(FILE)" ]; then \
		echo "${YELLOW}Error: File $(FILE) not found${RESET}"; \
		exit 1; \
	fi
	@echo "${BLUE}Tangling $(FILE)...${RESET}"
	@./scripts/tangle-org.sh "$(FILE)"
	@echo "${GREEN}Tangling complete!${RESET}"

# Tangle all org files (using the script)
tangle-all:
	@echo "${BLUE}Tangling all Org files...${RESET}"
	@./scripts/tangle-all.sh
	@echo "${GREEN}All Org files tangled!${RESET}"

# Build all source files from Org files
build: $(PY_TARGETS) $(HY_TARGETS)
	@echo "${GREEN}All source files built!${RESET}"

# Generate timestamp file for all generated sources
.tangled_sources: $(ORG_FILES)
	@echo "${BLUE}Rebuilding all tangled sources...${RESET}"
	@./scripts/tangle-all.sh
	@touch $@

# Paper summary rule - only regenerate if PDF or prompt template changes
%.summary.txt: %.pdf $(PROMPT_TEMPLATE)
	@echo "${BLUE}Generating summary for $<...${RESET}"
	@mkdir -p $(@D)
	@$(HY) src/paper_summarizer.hy $< $(PROMPT_TEMPLATE) $@
	@echo "${GREEN}Summary generated: $@${RESET}"

# Generate all paper summaries
paper-summaries: $(SUMMARY_TARGETS)
	@echo "${GREEN}All paper summaries generated!${RESET}"
	@echo "${YELLOW}Summaries can be found in papers/ directory with .summary.txt extension${RESET}"

# Extract French verbs from Verbiste XML
resources/verbs/french_verbs_list.txt: resources/xslt/verbiste_extract.xsl
	@echo "${BLUE}Extracting French verbs from verbiste XML...${RESET}"
	@mkdir -p resources/verbs
	@xml tr $< /usr/local/share/verbiste-0.1/verbs-fr.xml > $@
	@echo "${GREEN}French verbs extracted to $@${RESET}"
	@echo "${YELLOW}Total verbs: $$(wc -l < $@)${RESET}"

# Extract all French verbs (just once for initial setup)
extract-french-verbs: resources/verbs/french_verbs_list.txt
	@echo "${GREEN}French verb extraction complete!${RESET}"
	@echo "${YELLOW}Use resources/verbs/test_french_verbs.txt for embedding tests${RESET}"

# Test environment setup for Google API
env-test:
	@echo "${BLUE}Testing environment setup...${RESET}"
	@$(HY) src/env_test.hy
	@echo "${GREEN}Environment test complete!${RESET}"

# Test Google GenAI API functionality
test-genai:
	@echo "${BLUE}Testing Google GenAI API functionality...${RESET}"
	@$(HY) src/test/test_genai.hy
	@echo "${GREEN}GenAI API test complete!${RESET}"

# Generate embeddings for French verbs
verb-embeddings: resources/verbs/test_french_verbs.txt
	@echo "${BLUE}Running French verb embeddings...${RESET}"
	@$(HY) src/embeddings/verb_embeddings.hy
	@echo "${GREEN}Verb embeddings complete!${RESET}"

# Run the dépatouiller test (for debugging embedding problems)
dépatouiller:
	@echo "${BLUE}Running dépatouiller test...${RESET}"
	@$(HY) src/embeddings/dépatouiller.hy
	@echo "${GREEN}Dépatouillage complete!${RESET}"

# Test Google GenAI embeddings
genai-embeddings:
	@echo "${BLUE}Testing Google GenAI embeddings for French verbs...${RESET}"
	@$(HY) src/embeddings/genai.hy
	@echo "${GREEN}GenAI embeddings test complete!${RESET}"

# Run verb similarity analysis
verb-similarity:
	@echo "${BLUE}Analyzing French verb similarity with embeddings...${RESET}"
	@$(HY) src/embeddings/verb_similarity.hy
	@echo "${GREEN}Verb similarity analysis complete!${RESET}"

# Run simple verb matrix
verb-matrix:
	@echo "${BLUE}Generating minimal French verb similarity matrix...${RESET}"
	@$(HY) src/embeddings/verb_matrix.hy
	@echo "${GREEN}Verb matrix complete!${RESET}"