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
SCLEAR_TIME=2
SAFE_MODE=true
SHOW_ALL=true
LOG_FILE="osus.log"
# ======================

# === Main colors ===
OSUS_PINK='\033[38;5;205m'
OSUS_RESET='\033[0m'
# === Other colors (extra) ===
OSUS_COLOR_1="\033[38;5;245m"
OSUS_COLOR_2='\033[38;5;235m'
OSUS_COLOR_3='\033[38;5;225m'
OSUS_COLOR_4='\033[38;5;215m'
OSUS_COLOR_5='\033[38;5;195m'
OSUS_COLOR_6='\033[38;5;185m'
OSUS_COLOR_7='\033[38;5;175m'
OSUS_COLOR_8='\033[38;5;165m'
OSUS_COLOR_9='\033[38;5;155m'
OSUS_COLOR_10='\033[38;5;145m'
OSUS_COLOR_11='\033[38;5;135m'
OSUS_COLOR_12='\033[38;5;125m'
OSUS_COLOR_13='\033[38;5;115m'
OSUS_COLOR_14='\033[38;5;105m'
OSUS_COLOR_15='\033[38;5;95m'
OSUS_COLOR_16='\033[38;5;85m'
OSUS_COLOR_17='\033[38;5;75m'
OSUS_COLOR_18='\033[38;5;65m'
OSUS_COLOR_19='\033[38;5;55m'
OSUS_COLOR_20='\033[38;5;45m'
OSUS_COLOR_21='\033[38;5;35m'
OSUS_COLOR_22='\033[38;5;25m'
OSUS_COLOR_23='\033[38;5;15m'
OSUS_COLOR_24='\033[38;5;5m'

# === Arguments ===
ACTION="PROCESS"
DEBUG_MODE=false
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
            DEBUG_MODE=true
            SHOW_ALL=true
            shift
            ;;
        *)
            echo -e "${OSUS_PINK}Unknown argument: $1${OSUS_RESET}"
            exit 1
            ;;
    esac
done

ENABLE_LOG=false
if [ "$DEBUG_MODE" = true ] || [ -n "$LOG_FILE" ]; then
    ENABLE_LOG=true
    log_dir=$(dirname "$LOG_FILE")
    if [ "$log_dir" != "." ] && [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir" 2>/dev/null
    fi
    echo "=== osus!droid extractor log started: $(date) ===" > "$LOG_FILE" 2>/dev/null
fi

log_msg() {
    local level="$1"
    local message="$2"
    if [ "$ENABLE_LOG" = true ] && [ -n "$LOG_FILE" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE" 2>/dev/null
    fi
}

# Check utils
if ! command -v stat &> /dev/null; then
    echo -e "${OSUS_PINK}Util: [stat] not found${OSUS_RESET}"
    log_msg "ERROR" "Util: [stat] not found"
    exit 1
fi

if ! command -v awk &> /dev/null; then
    echo -e "${OSUS_PINK}Util: [awk] not found${OSUS_RESET}"
    log_msg "ERROR" "Util: [awk] not found"
    exit 1
fi

# Check if directory valid
if [ ! -d "$SONGS_DIR" ]; then
    echo -e "${OSUS_PINK}Directory $SONGS_DIR not found${OSUS_RESET}"
    log_msg "ERROR" "Directory $SONGS_DIR not found"
    exit 1
fi

# size limit:)
MAX_SIZE_BYTES=$(awk "BEGIN {printf \"%.0f\", $MAX_SIZE_MB * 1024 * 1024}")


# clear terminal bwa
csh() {
    sleep $SCLEAR_TIME
    clear
}

# New line
nline() {
    echo -e "\n"
}

# Separators :3
# Reset
sepp_r() {
    echo -e "${OSUS_RESET}---------------------------------------------"
}

# Pink
sepp_p() {
    echo -e "${OSUS_PINK}---------------------------------------------${OSUS_RESET}"
}

cduplicate() {
    local filename="$1"
    local dest="$2"
    
    if [ -f "$dest" ]; then
        return 0
    fi
    return 1
}

csuslare() {
    local folder_name="$1"
    local output_dir="$2"
    
    if ls "$output_dir" 2>/dev/null | grep -qi "${folder_name}"; then
        return 0
    fi
    return 1
}

gaudiof() {
    local song_dir="$1"
    local osu_file=""
    
    for file in "$song_dir"*.osu; do
        if [ -f "$file" ]; then
            osu_file="$file"
            break
        fi
    done
    
    if [ -z "$osu_file" ] || [ ! -f "$osu_file" ]; then
        echo ""
        return 1
    fi
    
    local audio_filename=$(grep -i "^AudioFilename:" "$osu_file" | head -n 1 | cut -d':' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    echo "$audio_filename"
}

if [ "$ACTION" = "LIST" ]; then
    echo -e "${OSUS_RESET}Scanning for available songs in:${OSUS_PINK} $SONGS_DIR"
    echo -e "Limit: ${MAX_SIZE_MB}MB (${MAX_SIZE_BYTES} bytes)"
    log_msg "INFO" "Scanning $SONGS_DIR with limit ${MAX_SIZE_MB}MB"
    sepp_r
    
    foundc=0
    for song_dir in "$SONGS_DIR"/*/; do
        audio_filename=$(gaudiof "$song_dir")
        
        if [ -n "$audio_filename" ]; then
            audio_file="${song_dir}${audio_filename}"
            
            if [ -f "$audio_file" ]; then
                file_size=$(stat -c%s "$audio_file")
                folder_name=$(basename "$song_dir")
                ext="${audio_filename##*.}"
                
                if [ "$file_size" -le "$MAX_SIZE_BYTES" ]; then
                    new_filename="${folder_name}_osu!droid.${ext}"
                    dest_path="${OUTPUT_DIR}/${new_filename}"
                    
                    status="[OK]"
                    if cduplicate "$new_filename" "$dest_path"; then
                        status="[DUP]"
                    elif csuslare "$folder_name" "$OUTPUT_DIR"; then
                        status="[SUS]"
                    fi
                    
                    echo -e "${status} ${OSUS_PINK}${folder_name}.${ext}${OSUS_RESET} | ${file_size} byte | ${audio_filename}"
                    log_msg "INFO" "Found: ${folder_name}.${ext} | ${file_size} byte | ${audio_filename}"
                    ((foundc++))
                else
                    if [ "$SHOW_ALL" = true ]; then
                        echo -e "[SKIP] ${folder_name}.${ext} | ${file_size} byte | ${audio_filename}"
                        log_msg "SKIP" "Too large: ${folder_name}.${ext} | ${file_size} byte"
                    fi
                fi
            else
                if [ "$SHOW_ALL" = true ]; then
                    echo -e "[ERR] ${OSUS_PINK}${folder_name}${OSUS_RESET} | not found audio: ${audio_filename}"
                fi
                log_msg "ERROR" "not found audio: ${folder_name} -> ${audio_filename}"
            fi
        else
            if [ "$SHOW_ALL" = true ]; then
                folder_name=$(basename "$song_dir")
                echo -e "[ERR] ${OSUS_PINK}${folder_name}${OSUS_RESET} | .osu file or AudioFilename not found"
            fi
            log_msg "ERROR" ".osu file or AudioFilename: $(basename "$song_dir")"
        fi
    done
    sepp_p
    echo -e "Total available files: ${OSUS_PINK}[$foundc]${OSUS_RESET}"
    log_msg "INFO" "$foundc files found"
    exit 0
fi

mkdir -p "$OUTPUT_DIR"

csh
echo -e "${OSUS_PINK}OSUS!${OSUS_RESET}droid -${OSUS_COLOR_3} Song extractor"
echo -e "${OSUS_PINK}by ${OSUS_COLOR_10}github.com/${GITHUB_LINK}"
csh
sepp_p
echo -e "${OSUS_PINK}Directory:${OSUS_RESET} $SONGS_DIR"
echo -e "${OSUS_PINK}Output:${OSUS_RESET} $OUTPUT_DIR"
echo -e "${OSUS_PINK}SizeLimit:${OSUS_RESET} ${MAX_SIZE_MB}MB - ${MAX_SIZE_BYTES}byte"
nline
echo -e "${OSUS_PINK}Mode:${OSUS_RESET} $([ "$SAFE_MODE" = true ] && echo 'SAFE' || echo 'UNSAFE')"

log_msg "INFO" "SONGS_DIR: $SONGS_DIR, OUTPUT_DIR: $OUTPUT_DIR, MAX_SIZE: ${MAX_SIZE_MB}MB, SAFE_MODE: $SAFE_MODE"
csh
sepp_r

foundc=0
total=0
skipped=0
duplicates=0
suslare=0
errors=0

for song_dir in "$SONGS_DIR"/*/; do
    audio_filename=$(gaudiof "$song_dir")
    
    if [ -n "$audio_filename" ]; then
        audio_file="${song_dir}${audio_filename}"
        
        if [ -f "$audio_file" ]; then
            ((total++))
            file_size=$(stat -c%s "$audio_file")
            folder_name=$(basename "$song_dir")
            ext="${audio_filename##*.}"

            if [ "$file_size" -le "$MAX_SIZE_BYTES" ]; then
                new_filename="${folder_name}_osu!droid.${ext}"
                dest_path="${OUTPUT_DIR}/${new_filename}"

                if cduplicate "$new_filename" "$dest_path"; then
                    echo -e "${OSUS_PINK}[DUP]${OSUS_RESET} ${folder_name} | File already exists"
                    log_msg "DUP" "File exists: ${new_filename}"
                    ((duplicates++))
                    continue
                fi

                if csuslare "$folder_name" "$OUTPUT_DIR"; then
                    echo -e "${OSUS_PINK}[SUS]${OSUS_RESET} ${folder_name} | suslare found"
                    log_msg "SUS" "suslare: ${folder_name}"
                    ((suslare++))
                    continue
                fi

                if [ "$SAFE_MODE" = true ]; then
                    cp "$audio_file" "$dest_path"
                else
                    new_filename="${folder_name}"
                    dest_path="${OUTPUT_DIR}/${new_filename}"
                    mv "$SONGS_DIR/$folder_name" "$dest_path"
                fi

                if [ $? -eq 0 ]; then
                    echo -e "[OK] ${OSUS_PINK}${folder_name}${OSUS_RESET} | ${file_size}byte | ${audio_filename}"
                    log_msg "OK" "Processed: ${folder_name} | ${file_size}byte | ${audio_filename}"
                    ((foundc++))
                else
                    echo -e "${OSUS_PINK}[FAIL] Failed move song from ${folder_name}${OSUS_RESET}"
                    log_msg "ERROR" "Failed to copy or move: ${folder_name} -> ${dest_path}"
                fi
            else
                if [ "$SHOW_ALL" = true ]; then
                    echo -e "[SKIP] ${folder_name} | ${file_size}byte | ${audio_filename}"
                fi
                log_msg "SKIP" "Too large: ${folder_name} | ${file_size}byte"
                ((skipped++))
            fi
        else
            folder_name=$(basename "$song_dir")
            echo -e "${OSUS_PINK}[ERR]${OSUS_RESET} ${folder_name} | not found audio: ${audio_filename}"
            log_msg "ERROR" "not found audio: ${folder_name} -> ${audio_filename}"
            ((errors++))
        fi
    else
        folder_name=$(basename "$song_dir")
        echo -e "${OSUS_PINK}[ERR]${OSUS_RESET} ${folder_name} | .osu file or AudioFilename not found"
        log_msg "ERROR" ".osu file or AudioFilename: ${folder_name}"
        ((errors++))
    fi
done

csh
sepp_r
echo -e "Total found maps: ${OSUS_PINK}[$total]${OSUS_RESET}"
echo -e "Songs Count: ${OSUS_PINK}[$foundc]${OSUS_RESET}"
echo -e "Skipped: ${OSUS_PINK}[$skipped]${OSUS_RESET}"
echo -e "Suslares: ${OSUS_PINK}[$suslare]${OSUS_RESET}"
echo -e "Duplicates: ${OSUS_PINK}[$duplicates]${OSUS_RESET}"
echo -e "Errors: ${OSUS_PINK}[$errors]${OSUS_RESET}"
sepp_p

log_msg "INFO" "total: $total, found: $foundc, skipped: $skipped, dup: $duplicates, sus: $suslare, errors: $errors"