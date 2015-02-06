#!/bin/bash
#
# Run this script as root from a fresh git checkout to run the Blue Box NOC.
#
# Variables in BLUEBOXNOC_ALL_CAPS style below may be overridden in
# the environment, e.g.
#
# BLUEBOXNOC_VAR_DIR=/srv/blueboxnoc install_noc.sh

set -e -x

cd "$(dirname "$0")"
. shlib/functions.sh

: ${BLUEBOXNOC_CODE_DIR:="$PWD"}

ensure_running_as_root
ensure_docker 1.4.0

: ${BLUEBOXNOC_DOCKER_NAME:=epflsti/blueboxnoc}
docker images -q "$BLUEBOXNOC_DOCKER_NAME" | wc -l || {
    docker -t "$BLUEBOXNOC_DOCKER_NAME":prod .
}

substitute_shell BLUEBOXNOC_ < run_noc.sh > /etc/init.d/blueboxnoc

set +x
echo
echo "All done, now see run_noc.sh"
echo
