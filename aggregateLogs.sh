#!/bin/bash

# === Configurable Constants ===
EVENT_TIME_KEY="YOURTIMESTAMPFIELD"
OUTPUT_PREFIX="YOURPREFIX"

# ^^^^^^^^^^SET THIS FIELDS ^^^^^^^^^^^^

# Create a temporary directory for intermediate files
temp_dir=$(mktemp -d)

# Function to extract and print lines with their eventTime prepended
extract_eventTime() {
  local file="$1"
  local temp_file="$2"
  awk -v key="$EVENT_TIME_KEY" '{
    pattern = sprintf("\"%s\":\"([^\"]+)\"", key);
    match($0, pattern, arr);
    if (RSTART != 0) {
      print arr[1] " " $0;
    }
  }' "$file" > "$temp_file"
}

# Function to process a single log file
process_single_log() {
  local log_file="$1"
  local temp_file="${temp_dir}/$(basename "$log_file").tmp"
  extract_eventTime "$log_file" "$temp_file"
}

# Export functions and variables for GNU Parallel
export -f extract_eventTime
export -f process_single_log
export temp_dir
export EVENT_TIME_KEY

# Process log files in parallel using GNU Parallel
find . -name '*.log' | parallel -j 4 process_single_log

# Merge and write sorted output
merge_and_write() {
  local output_count=1
  local row_count=0

  sort -m "${temp_dir}/"*.tmp | while read -r line; do
    if (( row_count >= 10000 )); then
      output_count=$((output_count + 1))
      row_count=0
    fi

    echo "${line#* }" >> "${OUTPUT_PREFIX}${output_count}.log"
    row_count=$((row_count + 1))

    if (( row_count % 500 == 0 )); then
      echo "Written $row_count rows to ${OUTPUT_PREFIX}${output_count}.log"
    fi
  done
}

# Run the merging and writing function
merge_and_write

# Clean up temporary files
rm -r "$temp_dir"

echo "Processing complete."
