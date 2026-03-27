#!/bin/bash
# Arguments:
# -ls — Scan $SONGS_DIR for available songs
# -debug — Enable debug mode
# -d — $SONGS_DIR
# -o — $OUTPUT_DIR
# -s — Sets file size limit $MAX_SIZE_MB
# -sf — Enable/Disable SAFE_MODE req dont touch it, only for pros (coz he deleting files from $SONGS_DIR)

# === Config ===
GITHUB_LINK="wh1tesh1t"
SONGS_DIR="/storage/emulated/0/osu!droid/Songs"
OUTPUT_DIR="/storage/emulated/0/osu!droid_songs"
MAX_SIZE_MB=35.0
SAFE_MODE=true
SHOW_ALL=false
# ======================

# === Colors ===
OSUS_PINK='\033[38;5;206m'
OSUS_RESET='\033[0m'

# === Arguments ===
ACTION="PROCESS"
while [[ $# -gt 0 ]]; do
    case $1 in
        -ls)
            ACTION="LIST"
            shift
            ;;
        -d)
            SONGS_DIR="$2"
            shift 2
            ;;
        -o)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -s)
            MAX_SIZE_MB="$2"
            shift 2
            ;;
        -sf)
            if [ "$2" = "false" ]; then
                SAFE_MODE=false
            else
                SAFE_MODE=true
            fi
            shift 2
            ;;
        -debug)
            SHOW_ALL=true
            shift
            ;;
        *)
            echo -e "${OSUS_PINK}Unknown argument: $1${OSUS_RESET}"
            exit 1
            ;;
    esac
done

# Check utils
if ! command -v stat &> /dev/null; then
    echo -e "${OSUS_PINK}Util: [stat] not found${OSUS_RESET}"
    exit 1
fi

if ! command -v awk &> /dev/null; then
    echo -e "${OSUS_PINK}Util: [awk] not found${OSUS_RESET}"
    exit 1
fi

# Check if directory valid
if [ ! -d "$SONGS_DIR" ]; then
    echo -e "${OSUS_PINK}Directory $SONGS_DIR not found${OSUS_RESET}"
    exit 1
fi

# size limit:)
MAX_SIZE_BYTES=$(awk "BEGIN {printf \"%.0f\", $MAX_SIZE_MB * 1024 * 1024}")

cduplicate() {
    local filename="$1"
    local dest="$2"
    
    if [ -f "$dest" ]; then
        return 0
    fi
    return 1
}

if [ "$ACTION" = "LIST" ]; then
    echo -e "${OSUS_PINK}Scanning for available songs in: $SONGS_DIR${OSUS_RESET}"
    echo -e "Limit: ${MAX_SIZE_MB}MB (${MAX_SIZE_BYTES} bytes)"
    echo "---------------------------------------------"
    
    count=0
    for song_dir in "$SONGS_DIR"/*/; do
        audio_file_mp3="${song_dir}audio.mp3"
        audio_file_ogg="${song_dir}audio.ogg"
        target_file=""
        ext=""
        
        if [ -f "$audio_file_mp3" ]; then
            target_file="$audio_file_mp3"
            ext="mp3"
        elif [ -f "$audio_file_ogg" ]; then
            target_file="$audio_file_ogg"
            ext="ogg"
        fi

        if [ -n "$target_file" ] && [ -f "$target_file" ]; then
            file_size=$(stat -c%s "$target_file")
            folder_name=$(basename "$song_dir")
            
            if [ "$file_size" -le "$MAX_SIZE_BYTES" ]; then
                new_filename="${folder_name}_osu!droid.${ext}"
                dest_path="${OUTPUT_DIR}/${new_filename}"
                
                status="[OK]"
                if cduplicate "$new_filename" "$dest_path"; then
                    status="[DUP]"
                fi
                
                echo -e "${status} ${OSUS_PINK}${folder_name}.${ext}${OSUS_RESET} | ${file_size} byte"
                ((count++))
            else
                if [ "$SHOW_ALL" = true ]; then
                    echo -e "[SKIP] ${folder_name}.${ext} | ${file_size} byte"
                fi
            fi
        fi
    done
    echo "---------------------------------------------"
    echo -e "Total available files: ${OSUS_PINK}$count${OSUS_RESET}"
    exit 0
fi

mkdir -p "$OUTPUT_DIR"

clear
echo -e "${OSUS_PINK}osus!${OSUS_RESET}droid - Song extctractor"
echo -e "${OSUS_PINK}by ${OSUS_RESET}github.com/${GITHUB_LINK}"
sleep 5
echo -e "\n\n\n"
echo -e "${OSUS_PINK}Directory:${OSUS_RESET} $SONGS_DIR"
echo -e "${OSUS_PINK}Output:${OSUS_RESET} $OUTPUT_DIR"
echo -e "${OSUS_PINK}SizeLimit:${OSUS_RESET} ${MAX_SIZE_MB}mb - ${MAX_SIZE_BYTES}byte"
echo -e "${OSUS_PINK}Mode:${OSUS_RESET} $([ "$SAFE_MODE" = true ] && echo 'SAFE' || echo 'UNSAFE')"
echo -e "${OSUS_PINK}Debug:${OSUS_RESET} $SHOW_ALL"
echo "---------------------------------------------"

count=0
total=0
skipped=0
duplicates=0

for song_dir in "$SONGS_DIR"/*/; do
    audio_file_mp3="${song_dir}audio.mp3"
    audio_file_ogg="${song_dir}audio.ogg"
    audio_file=""
    ext=""

    if [ -f "$audio_file_mp3" ]; then
        audio_file="$audio_file_mp3"
        ext="mp3"
    elif [ -f "$audio_file_ogg" ]; then
        audio_file="$audio_file_ogg"
        ext="ogg"
    fi

    if [ -n "$audio_file" ] && [ -f "$audio_file" ]; then
        ((total++))
        file_size=$(stat -c%s "$audio_file")
        folder_name=$(basename "$song_dir")

        if [ "$file_size" -le "$MAX_SIZE_BYTES" ]; then
            new_filename="${folder_name}_osu!droid.${ext}"
            dest_path="${OUTPUT_DIR}/${new_filename}"

            if cduplicate "$new_filename" "$dest_path"; then
                echo -e "${OSUS_PINK}[DUP]${OSUS_RESET} ${folder_name} | File already exists"
                ((duplicates++))
                continue
            fi

            if [ "$SAFE_MODE" = true ]; then
                cp "$audio_file" "$dest_path"
            else
                mv "$audio_file" "$dest_path"
            fi

            if [ $? -eq 0 ]; then
                echo -e "[OK] ${OSUS_PINK}${folder_name}${OSUS_RESET} | ${file_size}byte"
                ((count++))
            else
                echo -e "${OSUS_PINK}[FAIL] Failed move song from ${folder_name}${OSUS_RESET}"
            fi
        else
            if [ "$SHOW_ALL" = true ]; then
                echo -e "[SKIP] ${folder_name} | ${file_size}byte"
            fi
            ((skipped++))
        fi
    fi
done

echo "---------------------------------------------"
echo -e "Total found maps: ${OSUS_PINK}$total${OSUS_RESET}"
echo -e "Songs Count: ${OSUS_PINK}$count${OSUS_RESET}"
echo -e "Skipped/Duplicates: ${OSUS_PINK}$skipped / $duplicates${OSUS_RESET}"