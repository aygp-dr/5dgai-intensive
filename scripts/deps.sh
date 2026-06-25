#!/usr/bin/env bash
# Check for required dependencies for the 5-Day Gen AI Intensive
set -euo pipefail

echo "Checking required dependencies..."

# Core dependencies
REQUIRED=("python3" "poetry" "emacs")
OPTIONAL=("hy")

# Check required tools
for cmd in "${REQUIRED[@]}"; do
  if command -v "$cmd" &>/dev/null; then
    echo "✅ $cmd found"
  else
    echo "❌ $cmd not found - required for this repository"
  fi
done

# Check optional tools
echo ""
echo "Optional dependencies:"
for cmd in "${OPTIONAL[@]}"; do
  if command -v "$cmd" &>/dev/null; then
    echo "✅ $cmd found"
  else
    echo "⚠️ $cmd not found - can be installed with poetry if needed"
  fi
done

# Check Python version
echo ""
echo "Checking Python version..."
python_version=$(python3 --version 2>&1 | awk '{print $2}')
python_major=$(echo "$python_version" | cut -d. -f1)
python_minor=$(echo "$python_version" | cut -d. -f2)

if [ "$python_major" -lt 3 ] || { [ "$python_major" -eq 3 ] && [ "$python_minor" -lt 11 ]; }; then
  echo "⚠️ Python 3.11+ recommended (found $python_version)"
else
  echo "✅ Python $python_version"
fi

# Check Emacs version
echo ""
echo "Checking Emacs version..."
if command -v emacs &>/dev/null; then
  emacs_version=$(emacs --version | head -n 1 | awk '{print $3}')
  echo "✅ Emacs $emacs_version"
else
  echo "⚠️ Emacs not found"
fi

# Finish
echo ""
echo "Dependency check complete."
echo "This repository uses Hy (a Lisp dialect) and Org-mode for the 5-Day Gen AI Intensive course."
echo "If you prefer Python and Jupyter notebooks, please note this repository uses an alternative approach."