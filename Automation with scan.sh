#!/bin/bash
# This example script automates running subfinder, httpx, and nuclei tools on a target domain or list of domains.
# It supports running each tool individually or chaining them together in a workflow.

# Usage: ./script.sh <domain|file> <subfinder|httpx|nuclei|chain>

INPUT=$1    # First argument: domain name or path to file containing domains
MODE=$2     # Second argument: mode of operation (which tool or chain to run)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")  # Current timestamp for unique output directory naming

# Check if both INPUT and MODE are provided
if [[ -z $INPUT || -z $MODE ]]; then
  echo "Usage: $0 <domain|file> <subfinder|httpx|nuclei|chain>"
  exit 1
fi

# Check if INPUT is a file (batch mode)
if [[ -f $INPUT ]]; then
  # Read each line (domain) from the file and recursively call this script on each domain
  while IFS= read -r domain; do
    # Only process non-empty lines
    [[ $domain ]] && bash "$0" "$domain" "$MODE"
  done < "$INPUT"
  exit 0
fi

# If not batch mode, treat INPUT as a single domain
TARGET=$INPUT
OUT="outputs/$TARGET/$TIMESTAMP"   # Define output directory path for this run
mkdir -p "$OUT"                    # Create output directory (including parent directories if needed)

echo "[*] $MODE on $TARGET → $OUT"  # Informational message about current operation

# Select operation based on MODE argument
case $MODE in

  # Run subfinder to discover subdomains of TARGET
  subfinder)
    subfinder -d "$TARGET" -silent -o "$OUT/subs.txt"
    ;;

  # Run httpx to probe discovered subdomains for live HTTP services
  httpx)
    # Find the most recent subs.txt file for the target domain
    L=$(find outputs/$TARGET -name subs.txt | sort | tail -1)
    # Check if subs.txt file exists
    if [[ -f $L ]]; then
      httpx -l "$L" -silent -o "$OUT/httpx.txt"
    else
      echo "Run subfinder first"
      exit 1
    fi
    ;;

  # Run nuclei vulnerability scanner on live hosts found by httpx
  nuclei)
    # Find the most recent httpx.txt file for the target domain
    L=$(find outputs/$TARGET -name httpx.txt | sort | tail -1)
    # Check if httpx.txt file exists
    if [[ -f $L ]]; then
      nuclei -l "$L" -o "$OUT/nuclei.txt"
    else
      echo "Run httpx first"
      exit 1
    fi
    ;;

  # Chain mode: run all three tools sequentially on the target domain
  chain)
    subfinder -d "$TARGET" -silent -o "$OUT/subs.txt"
    httpx -l "$OUT/subs.txt" -silent -o "$OUT/httpx.txt"
    nuclei -l "$OUT/httpx.txt" -o "$OUT/nuclei.txt"
    ;;

  # Handle invalid mode argument
  *)
    echo "Invalid mode"
    exit 1
    ;;
esac

echo "[✔] Done!"   # Indicate completion of the operation
