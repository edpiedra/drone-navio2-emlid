#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "$0")
source "$SCRIPTS_DIR/00_common.env"
source "$SCRIPTS_DIR/00_lib.sh"

NAVIO_WHEEL_VERSION="navio2-1.0.0-py3-none-any.whl"
NAVIO2_WHEEL="$NAVIO2_PYTHON_DIR/dist/$NAVIO_WHEEL_VERSION"

log "checking to see if previous $SCRIPT_NAME install ran successfully..."
if [ -f "$DRONE_INSTALL_FLAG" ]; then 
    log "OpenNI SDK install was already run successfully..."
    exit 0
fi 

log "cloning pymavlink..."
cd $HOME 
if [ -d "pymavlink" ]; then 
    rm -rf "pymavlink"
fi 

git clone https://github.com/ArduPilot/pymavlink.git
cd pymavlink
mkdir -p message_definitions/
git clone https://github.com/mavlink/mavlink.git tmp_mavlink
mv tmp_mavlink/message_definitions/v1.0 message_definitions
rm -rf tmp_mavlink

log "installing system packages..."
sudo apt-get install -y -qq python3-opencv python3-numpy 
cd "$HOME/$REPO"

if [ ! -d .venv ]; then 
    log "creating virtual environment..."
    python3 -m venv .venv --system-site-packages
fi 

set +u; source .venv/bin/activate; set -u
python3 -m pip install "$NAVIO2_WHEEL"
python3 -m pip install -r requirements.txt
cd $HOME/pymavlink
python3 -m pip install . --no-use-pep517
set +u; deactivate; set -u

touch "$DRONE_INSTALL_FLAG"