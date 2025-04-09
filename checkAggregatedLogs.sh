#!/bin/bash

# === Configurable Constants ===
EVENT_TIME_KEY="YOURTIMESTAMPFIELD"

# Function to compare two ISO8601 timestamps
compare_dates() {
  date1=$1
  date2=$2

  # Convert ISO8601 to seconds since epoch
  timestamp1=$(date -d "$date1" +%s)
  timestamp2=$(date -d "$date2" +%s)

  if [ "$timestamp1" -gt "$timestamp2" ]; then
    return 1
  else
    return 0
  fi
}

# Function to process a single file
process_file() {
  file=$1
  thread_id=$2
  echo "Thread $thread_id: Processing file: $file"

  previous_event_time=""
  previous_line=""
  line_number=0

  # Read and discard the first line
  read -r first_line < "$file"
  line_number=$((line_number + 1))

  # Process the rest of the file
  while IFS= read -r line; do
    line_number=$((line_number + 1))

    # Extract eventTime field from the line using grep and the configurable key
    event_time=$(echo "$line" | grep -oP "(?<=\"${EVENT_TIME_KEY}\":\")[^\"]+" | head -n 1)

    if [ -z "$event_time" ]; then
      echo "Thread $thread_id: Warning: $EVENT_TIME_KEY field not found in line $line_number of file $file"
      continue
    fi

    if [ -n "$previous_event_time" ]; then
      compare_dates "$previous_event_time" "$event_time"
      if [ $? -ne 0 ]; then
        echo "   Thread $thread_id: Error: $EVENT_TIME_KEY out of order in file $file"
        echo "   Previous line ($line_number-1):    $previous_event_time"
        echo "   Current line ($line_number):       $event_time"
        # exit 1
      fi
    fi

    previous_event_time="$event_time"
    previous_line="$line"

    # Print progress every 500 lines
    if (( line_number % 500 == 0 )); then
      echo "Thread $thread_id: Processed $line_number lines in file $file"
    fi
  done < <(tail -n +2 "$file")

  echo "Thread $thread_id: File $file processed successfully."
}

export -f compare_dates
export -f process_file
export EVENT_TIME_KEY

# Check if there are any .log files in the current directory
if ls *.log 1> /dev/null 2>&1; then
  # Use GNU parallel to process each file concurrently, assigning thread IDs
  ls *.log | parallel --lb process_file {} {%}
else
  echo "No .log files found in the current directory."
  exit 1
fi

echo "All files processed successfully."
