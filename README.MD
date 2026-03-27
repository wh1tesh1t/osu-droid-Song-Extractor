# osus!droid - Powerfull bash script for exctract songs from osu!droid directory

## Clone
```bash
git clone https://github.com/wh1tesh1t/osu-droid-Song-Extractor
```

```bash
# config from osus.sh
SONGS_DIR="/storage/emulated/0/osu!droid/Songs"
OUTPUT_DIR="/storage/emulated/0/osu!droid_songs"
MAX_SIZE_MB=35.0 # No need desc <_>
SAFE_MODE=true # Enable/Disable safe mode (UNSAFE DELETE FILES FROM SONGS_DIR)
SHOW_ALL=false # Better dont touch it:)
```

```bash
# Arguments (FROM FILE):
# -ls — Scan $SONGS_DIR for available songs
# -debug — Enable debug mode
# -d — $SONGS_DIR
# -o — $OUTPUT_DIR
# -s — Sets file size limit $MAX_SIZE_MB
# -sf — Enable/Disable SAFE_MODE req dont touch it, only for pros (coz he deleting files from $SONGS_DIR)
```

## Before run the script
Update termux packages:
```bash
apt update && apt upgrade && pkg update && pkg upgrade
```

Enable storage:
```bash
termux-setup-storage
```

## Run
```bash
bash osus.sh
```