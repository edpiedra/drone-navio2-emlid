#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")

SCRIPTS_DIR="/home/pi/drone/install/scripts"
source "$SCRIPTS_DIR/00_common.env"
export LOG_FILE="/home/pi/logs/install.log"
source "$SCRIPTS_DIR/00_lib.sh"

BOOT_CONF="/boot/config.txt"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$BOOT_CONF.bak-${STAMP}"
REPO_OVERLAYS_DIR="$REPO/overlays"

require_root

log "copying Navio2 overlays..."
sudo cp $REPO_OVERLAYS_DIR/navio-rgb.dtbo /boot/overlays/

log "adding Navio2 overlays to $BOOT_CONF..."
if [[ ! -f "$BOOT_CONF" ]]; then
  echo "cannot find $BOOT_CONF" >&2
  exit 1
fi

cp -a "$BOOT_CONF" "$BACKUP"
log "backed up $BOOT_CONF -> $BACKUP"

ensure_line "dtoverlay" "navio-rgb"
ensure_line "enable_uart" "1"
ensure_line "dtparam" "spi=on"
