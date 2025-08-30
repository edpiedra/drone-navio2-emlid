#!/usr/bin/env bash 
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")

export SCRIPTS_DIR="/home/pi/drone/install/scripts"
source "$SCRIPTS_DIR/00_common.env"
source "$SCRIPTS_DIR/00_lib.sh"

if [[ "${1:-}" == "--reinstall" ]]; then 
    log "reinstalling all packages..."

    if [ -d "$LOG_DIR" ]; then 
        rm -rf "$LOG_DIR"
        mkdir "$LOG_DIR"
    fi 
fi 

if [ ! -d "$LOG_DIR" ]; then 
    mkdir "$LOG_DIR" 
fi

if [ -f $DRONE_INSTALL_FLAG ]; then 
    log "drone package already installed..."
    log "if you want to reinstall the package, use bash drone/install/install.sh --reinstall"

    exit 0
elif [ -f $NAVIO2_KERNEL_INSTALL_FLAG ]; then 
    log "post-navio2 kernel reboot tasks starting..."

    for step in "$MAIN_SCRIPTS_DIR"/2[0-9][0-9]_*.sh; do 
        run_step "$step"
    done 

    read -p "→ drone package installed. Logs saved to: $LOG_FILE.  Press ENTER to reboot." _
    sudo reboot
elif [ -f $EXPANSION_INSTALL_FLAG ]; then
    log "post-filesystem reboot tasks starting..."

    for step in "$MAIN_SCRIPTS_DIR"/1[0-9][0-9]_*.sh; do 
        run_step "$step"
    done 
else 
    if [ -f "$LOG_FILE" ]; then 
    rm -f "$LOG_FILE"
    fi 

    for step in "$SCRIPTS_DIR"/[0-9][0-9]_*.sh; do 
        run_step "$step"
    done 
fi 
