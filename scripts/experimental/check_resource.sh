#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

TARGET_DIR="$1"

OUTPUT_DIR="./outputs"
mkdir -p "$OUTPUT_DIR"

TIMESTAMP=$(date +"%Y%m%d%H%M%S")

find "$TARGET_DIR" -type f -name "*.hcl" | while read -r FILE; do
    FILENAME=$(basename "$FILE")
    OUTPUT_FILE="$OUTPUT_DIR/$FILENAME.log"
    echo "Processing: $FILE to $OUTPUT_FILE"
    python3 adaptable.py "$FILE" check_resource.j2 "$OUTPUT_FILE"
done

echo "Processing completed. Logs are saved in $OUTPUT_DIR"
