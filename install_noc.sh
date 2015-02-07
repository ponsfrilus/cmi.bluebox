#!/bin/bash
#
# Blue Box NOC installation script
#
# Run this as root from a fresh git checkout to install the .
#
# Variables in BLUEBOXNOC_ALL_CAPS style below may be overridden in
# the environment, e.g.
#
#   export BLUEBOXNOC_VAR_DIR=/var/snazzy/blueboxnoc
#   sudo install_noc.sh

set -e -x

cd "$(dirname "$0")"
. shlib/functions.sh

: ${BLUEBOXNOC_CODE_DIR:="$PWD"}

ensure_running_as_root
ensure_docker 1.4.0

: ${BLUEBOXNOC_DOCKER_NAME:=epflsti/blueboxnoc}
docker build -t "$BLUEBOXNOC_DOCKER_NAME":latest .

: ${BLUEBOXNOC_VAR_DIR:="/srv/blueboxnoc"}
mkdir -p "${BLUEBOXNOC_VAR_DIR}"

substitute_shell BLUEBOXNOC_ < run_noc.sh > /etc/init.d/blueboxnoc
chmod a+x /etc/init.d/blueboxnoc

set +x
echo
echo "All done, now see run_noc.sh"
echo
