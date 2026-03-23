#!/bin/bash
# Copyright (c) github.com/wh1tesh1t

# === Config ===
SONGS_DIR="/storage/emulated/0/osu!droid/Songs"
OUTPUT_DIR="/storage/emulated/0/osu!droid_songs"
MAX_SIZE_MB=35.0 # No need desc <_>
SAFE_MODE=true # Enable/Disable safe mode (UNSAFE DELETE FILES FROM SONGS_DIR)
SHOW_ALL=false # Better dont touch it:)
# ======

# Check utils
if ! command -v stat &> /dev/null; then
    echo "Util: [stat] not found"
    exit 1
fi

if ! command -v awk &> /dev/null; then
    echo "Util: [awk] not found"
    exit 1
fi

# Check if directory valid
if [ ! -d "$SONGS_DIR" ]; then
    echo "Directory $SONGS_DIR not found"
    exit 1
fi

# Start Start Start
mkdir -p "$OUTPUT_DIR"

MAX_SIZE_BYTES=$(awk "BEGIN {printf \"%.0f\", $MAX_SIZE_MB * 1024 * 1024}")

echo "Directory: $SONGS_DIR"
echo "Output: $OUTPUT_DIR"
echo "SizeLimit: ${MAX_SIZE_MB}mb - ${MAX_SIZE_BYTES}byte"
echo "Mode: $([ "$SAFE_MODE" = true ] && echo 'SAFE' || echo 'UNSAFE')"
echo "---------------------------------------------"

count=0
total=0
skipped=0

for song_dir in "$SONGS_DIR"/*/; do
    audio_file="${song_dir}audio.mp3"

    if [ -f "$audio_file" ]; then
        ((total++))
        file_size=$(stat -c%s "$audio_file")
        folder_name=$(basename "$song_dir")

        if [ "$file_size" -le "$MAX_SIZE_BYTES" ]; then
            new_filename="${folder_name}_osu!droid.mp3"
            dest_path="${OUTPUT_DIR}/${new_filename}"

            if [ "$SAFE_MODE" = true ]; then
                cp "$audio_file" "$dest_path"
            else
                mv "$audio_file" "$dest_path"
            fi

            if [ $? -eq 0 ]; then
                echo "[OK] ${folder_name} | ${file_size}byte"
                ((count++))
            else
                echo "[FAIL] Failed move song from ${folder_name}"
            fi
        else
            if [ "$SHOW_ALL" = true ]; then
                echo "[SKIP] ${folder_name} | ${file_size}byte"
            fi
            ((skipped++))
        fi
    fi
done

echo "---------------------------------------------"
echo "Total found maps: $total"
echo "Count: $count"
echo "Skipped: $skipped"
