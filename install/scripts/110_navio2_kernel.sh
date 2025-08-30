#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$SCRIPTS_DIR/00_common.env"
source "$SCRIPTS_DIR/00_lib.sh"

RCIO_REPO="rcio-dkms"
RCIO_GIT="https://github.com/emlid/$RCIO_REPO.git"

log "checking to see if previous install of $SCRIPT_NAME ran successfully..."
if [ -f "$NAVIO2_KERNEL_INSTALL_FLAG" ]; then 
    log "Navio2 package install was already run successfully..."
    exit 0
fi 

log "getting rcio-dkms source..."
cd $HOME 

if [ -d $RCIO_REPO ]; then 
    rm -rf $RCIO_REPO 
fi 

git clone "$RCIO_GIT"
cd "$RCIO_REPO"
make

log "updating dkms..."
version=`dkms status | head -1 | awk -F, '{print $2;}' | sed 's/ /rcio\//g'`
sudo dkms remove $version --all

log "re-launching kernel module..."
sudo modprobe -r rcio_spi
sudo insmod rcio_core.ko
sudo insmod rcio_spi.ko

log "adding Navio2 overlays..."
sudo bash "$MAIN_SCRIPTS_DIR/910_navio2_overlays.sh"

touch "$NAVIO2_KERNEL_INSTALL_FLAG"

read -p "→ Navio2 kernel and overlays installed. Press ENTER to reboot." _
sudo reboot