#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$MAIN_SCRIPTS_DIR/00_common.env"
source "$MAIN_SCRIPTS_DIR/00_lib.sh"

RCIO_GIT="git@github.com:emlid/rcio-dkms.git"

log "checking to see if previous install of $SCRIPT_NAME ran successfully..."
if [ -f "$NAVIO2_KERNEL_INSTALL_FLAG" ]; then 
    log "Navio2 package install was already run successfully..."
    exit 0
fi 

log "getting rcio-dkms source..."
cd $HOME 
git clone "$RCIO_GIT"
cd rcio-dkms-private
make distclean

log "updating dkms..."
sudo dkms remove rcio/0.6.6 --all
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