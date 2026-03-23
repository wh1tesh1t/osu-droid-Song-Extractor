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

## Run
Enable storage:
```bash
termux-setup-storage
```

```bash
bash osus.sh
```