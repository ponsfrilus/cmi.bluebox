#!/bin/bash
#
# Run this script as root from a fresh git checkout to run the Blue Box NOC.

set -e -x

: ${CHECKOUT_DIR:="$(dirname "$0")"}
cd "$CHECKOUT_DIR"

. shlib/functions.sh

ensure_running_as_root
ensure_docker 1.4.0

: ${DOCKER_IMAGE_NAME:=epflsti/blueboxnoc}
docker images -q "$DOCKER_IMAGE_NAME" | wc -l || {
    docker -t "$DOCKER_IMAGE_NAME":prod .
}

set +x
echo
echo "All done, now see run_noc.sh"
echo
