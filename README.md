# Log File Processor

A Bash script to extract, sort, and split large JSON-formatted log files by `<YOURTIMESTAMP>` using GNU Parallel for speed and efficiency.

## 📋 Features

- Extracts and prepends `<YOURTIMESTAMP>` values from log entries
- Processes `.log` files in parallel for faster execution
- Merges and sorts all log lines chronologically
- Splits output into multiple files (10,000 lines each)
- Displays progress every 500 lines
- Cleans up all temporary files after processing

## 🚀 Usage

### 1. Clone or download the script

```bash
git clone https://github.com/yourusername/log-file-processor.git
cd log-file-processor
```

### 2. Make the script executable
bash
Kopieren
Bearbeiten
chmod +x process_logs.sh

### 3. Run the script
bash
Kopieren
Bearbeiten
./process_logs.sh
The script will recursively search for all *.log files in the current directory and process them.

### ⚙️ Configuration
At the top of the script, you can change the following constants to match your log format:

bash
Kopieren
Bearbeiten
EVENT_TIME_KEY="<YOURTIMESTAMP>"             # JSON key to extract timestamps from
OUTPUT_PREFIX="<YOURPREFIX>"   # Prefix for the output files

### ✅ Requirements
Bash

GNU Parallel

Core Unix utilities (awk, sort, find, etc.)

### 📂 Output
The script generates output files in the format:

bash
Kopieren
Bearbeiten
<YOURPREFIX>1.log
<YOURPREFIX>2.log
...
Each file contains a maximum of 10,000 lines, sorted by <YOURTIMESTAMP>.

### 🧹 Cleanup
All temporary files are automatically removed at the end of the script. No manual cleanup is needed.

### 🧪 Example
Given input lines like:
```bash
{"<YOURTIMESTAMP>":"2025-04-09T12:00:00Z", "message":"First"}
{"<YOURTIMESTAMP>":"2025-04-09T11:59:00Z", "message":"Second"}
```

The sorted output will be:
```bash
{"<YOURTIMESTAMP>":"2025-04-09T11:59:00Z", "message":"Second"}
{"<YOURTIMESTAMP>":"2025-04-09T12:00:00Z", "message":"First"}
```