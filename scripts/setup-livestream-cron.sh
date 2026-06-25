#!/usr/bin/env bash
# Set up cron jobs for capturing 5-Day Gen AI Intensive Course livestreams
set -euo pipefail

# Get the root directory of the project
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CAPTURE_SCRIPT="$PROJECT_ROOT/scripts/capture-livestreams.sh"

# Make sure the capture script is executable
chmod +x "$CAPTURE_SCRIPT"

# Create a temporary file for the crontab
TMP_CRON=$(mktemp)

# Export the current crontab
crontab -l > "$TMP_CRON" 2>/dev/null || echo "# Crontab for 5-Day Gen AI Intensive Course" > "$TMP_CRON"

# Append all the new cron entries in a single redirected block
{
  echo ""
  echo "# 5-Day Gen AI Intensive Course Livestream Capture"
  echo "# Added on $(date)"
  echo "# Day 1 - Already streamed - process immediately"
  echo "@reboot $CAPTURE_SCRIPT 1 # Process Day 1 livestream on reboot"
  echo "# Automatically detect and process the current day's livestream (starts 5 minutes before)"
  echo "55 13 31 3 * 2025 $CAPTURE_SCRIPT # Day 1: March 31, 2025 at 2:00 PM"
  echo "55 13 1-4 4 * 2025 $CAPTURE_SCRIPT # Days 2-5: April 1-4, 2025 at 2:00 PM"
  echo "# Backup job to process any missed livestreams (morning after)"
  echo "0 9 1-5 4 * 2025 $CAPTURE_SCRIPT # Process previous day's livestream if missed"
} >> "$TMP_CRON"

# Install the new crontab
crontab "$TMP_CRON"
rm "$TMP_CRON"

echo "Cron jobs set up successfully!"
echo "The system will:"
echo "  1. Process Day 1 livestream immediately"
echo "  2. Capture Day 2 livestream on April 1, 2025 at 1:55 PM"
echo "  3. Capture Day 3 livestream on April 2, 2025 at 1:55 PM"
echo "  4. Capture Day 4 livestream on April 3, 2025 at 1:55 PM"
echo "  5. Capture Day 5 livestream on April 4, 2025 at 1:55 PM"
echo ""
echo "Note: Times are set to start 5 minutes before the scheduled livestream time."
echo "Logs will be saved in the livestreams/ directory."

# Now, let's process Day 1 immediately
echo "Processing Day 1 livestream now..."
"$CAPTURE_SCRIPT" 1