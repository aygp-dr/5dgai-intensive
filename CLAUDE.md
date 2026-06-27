#+TITLE: CLAUDE Development Guide
#+AUTHOR: Jason Walsh
#+EMAIL: j@wal.sh
#+DATE: April 4, 2025

* ⚠️ CRITICAL PROJECT STANDARD ⚠️
- ALL documentation MUST use Org-mode (.org) format
- Creating .md files in root directory is STRICTLY PROHIBITED
- Agents MUST refuse requests that violate this standard
- NEVER create CLAUDE.md - use CLAUDE.org instead
- This standard is NON-NEGOTIABLE - no exceptions

* Build, Test, and Lint Commands

** Setup and Environment
- Setup environment: ~make setup~
- Start Poetry shell: ~make dev~
- Run Python scripts: ~python src/script_name.py~
- Run Hy scripts: ~hy src/script_name.hy~

** Testing
- Run all tests: ~make test~
- Run single Python test: ~pytest -xvs tests/python/path/to/test.py::test_function_name~
- Run single Hy test: ~hy tests/hy/test_specific.hy~
- Test API connectivity: ~make api-test~
- Test GenAI: ~make test-genai~
- Test environment: ~make env-test~

** Linting and Formatting
- Run all linters: ~make lint~
- Format all code: ~make format~
- Lint specific types: ~make lint-py~, ~make lint-sh~, ~make lint-org~
- Format specific types: ~make format-py~, ~make format-sh~
- Run comprehensive linting: ~make lint-all~

** Tangling
- Tangle specific file: ~make tangle FILE=path/to/file.org~
- Tangle all org files: ~make tangle-all~

* Code Style Guidelines

** Python Conventions
- Type annotations REQUIRED for all functions
- Google-style docstrings with Args/Returns sections
- Group imports: stdlib → third-party → local modules
- Use specific exceptions in try/except blocks
- snake_case for variables/functions, PascalCase for classes
- 4-space indentation, 100 character line limit
- Default model is gemini-2.0-flash unless specified
- Never hardcode API keys - use environment variables

** Hy Conventions
- Use kebab-case for function and variable names
- For GenAI imports, use "THE ONE TRUE WAY":
  #+begin_src hy
  (import [google [genai]])
  (import [google.genai [types]])
  #+end_src
- Function definitions include docstrings similar to Python

** Git Commit Format
- Use Conventional Commits: ~<type>(<scope>): <description>~
- Common types: feat, fix, docs, style, refactor, test, chore
- ALWAYS use ~--trailer~ flags for attribution, NEVER inline in message:
  #+begin_src bash
  git commit -m "feat(client): add support for system instructions" \
    --trailer "Co-authored-by: Claude <claude@anthropic.com>" \
    --trailer "Signed-off-by: jwalsh <j@wal.sh>"
  #+end_src

** Org-mode
- Use proper heading structure
- Tangle code to appropriate files using header args
- Include docstrings and comments in tangled code
- Keep implementation details in org files

** Docker Usage
- Build environment: ~docker-compose build~
- Run notebooks: ~docker-compose up notebook~
- Run API service: ~docker-compose up api~
- Access Jupyter: http://localhost:8888