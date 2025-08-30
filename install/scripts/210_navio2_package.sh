#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$SCRIPTS_DIR/00_common.env"
source "$SCRIPTS_DIR/00_lib.sh"

NAVIO2_GIT="https://github.com/emlid/Navio2.git"
NAVIO2_PACKAGE_INSTALL_FLAG="$LOG_DIR/navio2-package"

log "checking to see if previous install of $SCRIPT_NAME ran successfully..."
if [ -f "$NAVIO2_PACKAGE_INSTALL_FLAG" ]; then 
    log "Navio2 package install was already run successfully..."
    exit 0
fi 

log "installing system dependencies..."
sudo apt-get install git cmake g++ python3 python3-pip python3-venv screen -y -qq

log "cloning from $NAVIO2_GIT..."

if [ -d "$NAVIO2_DIR" ]; then 
    rm -rf "$NAVIO2_DIR"
fi 

cd "$HOME"
git clone "$NAVIO2_GIT"

log "creating navio2 python wheel..."
cd "$NAVIO2_PYTHON_DIR" || { log "missing $NAVIO2_PYTHON_DIR"; exit 1; }
python3 -m venv env --system-site-packages
set +u; source env/bin/activate; set -u
python3 -m pip install wheel
python3 setup.py bdist_wheel
set +u; deactivate; set -u

touch "$NAVIO2_PACKAGE_INSTALL_FLAG"