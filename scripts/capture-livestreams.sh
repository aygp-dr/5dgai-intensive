#!/usr/bin/env bash
# Script to capture 5-Day Gen AI Intensive Course livestreams
set -euo pipefail

# Get the root directory of the project
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Livestream URLs and schedule
declare -A LIVESTREAMS=(
  ["day1"]="https://www.youtube.com/watch?v=WpIfAeCIFc0"  # Already streamed on 3/31/25
  ["day2"]="https://www.youtube.com/watch?v=AjpjCHdIINU"  # Scheduled for 4/1/25, 2:00 PM
  ["day3"]="https://www.youtube.com/watch?v=g6MVIEzFTjY"  # Scheduled for 4/2/25, 2:00 PM
  ["day4"]="https://www.youtube.com/watch?v=AN2tpHi26OE"  # Scheduled for 4/3/25, 2:00 PM
  ["day5"]="https://www.youtube.com/watch?v=eZ-8UQ_t4YM"  # Scheduled for 4/4/25, 2:00 PM
)

# Process a single day's livestream
capture_livestream() {
  local day=$1
  local url=$2
  local day_number="${day#day}"
  local output_dir="$PROJECT_ROOT/livestreams"
  
  echo "Starting capture for $day (Day $day_number) at $(date)"
  echo "URL: $url"
  
  # Create output directory if it doesn't exist
  mkdir -p "$output_dir"
  
  # For archived streams (day1), use --archive flag
  if [[ "$day" == "day1" ]]; then
    echo "Processing archived stream for Day 1"
    cd "$PROJECT_ROOT" && \
    poetry run hy src/livestream_transcriber.hy "$url" \
      --archive \
      --day "$day_number" \
      --model "medium" \
      --output-dir "$output_dir" \
      >> "$output_dir/${day}_processing.log" 2>&1
  else
    # For upcoming livestreams, capture when they start
    echo "Setting up livestream capture for $day"
    cd "$PROJECT_ROOT" && \
    poetry run hy src/livestream_transcriber.hy "$url" \
      --day "$day_number" \
      --model "medium" \
      --summary-interval 600 \
      --output-dir "$output_dir" \
      >> "$output_dir/${day}_processing.log" 2>&1
  fi
  
  echo "Capture complete for $day at $(date)"
}

# Determine the day based on current date (2025)
get_current_day() {
  local day_of_year
  local year

  day_of_year=$(date +"%j")
  year=$(date +"%Y")
  
  # 2025 days: Mar 31 (day 90), Apr 1-4 (days 91-94)
  if [[ "$year" == "2025" ]]; then
    case "$day_of_year" in
      "090") # March 31, 2025
        echo "day1"
        ;;
      "091") # April 1, 2025
        echo "day2"
        ;;
      "092") # April 2, 2025
        echo "day3"
        ;;
      "093") # April 3, 2025
        echo "day4"
        ;;
      "094") # April 4, 2025
        echo "day5"
        ;;
      *)
        if [[ "$day_of_year" -lt "090" ]]; then
          echo "Course hasn't started yet. First livestream is on March 31, 2025."
          return 1
        elif [[ "$day_of_year" -gt "094" ]]; then
          echo "Course has ended. You can still process archived streams with day number argument."
          return 1
        fi
        ;;
    esac
  else
    echo "Not in 2025. Please specify the day number explicitly."
    return 1
  fi
  
  return 0
}

# Process command-line arguments
if [[ $# -gt 0 ]]; then
  day="day$1"
  if [[ -n "${LIVESTREAMS[$day]:-}" ]]; then
    capture_livestream "$day" "${LIVESTREAMS[$day]}"
  else
    echo "Invalid day number. Please specify a number between 1 and 5."
    exit 1
  fi
else
  # Try to determine the current day automatically
  current_day=$(get_current_day) || { echo "$current_day"; exit 1; }
  echo "Auto-detected day: $current_day"
  capture_livestream "$current_day" "${LIVESTREAMS[$current_day]}"
fi