#!/bin/sh

# Start or stop the Docker image for blueboxnoc
#
# Can be used / installed as a SysV startup script

: ${DOCKER_IMAGE_NAME:=epflsti/blueboxnoc}  # Like in install_noc.sh

start() {
    test 0 '!=' $(docker ps -q "$DOCKER_IMAGE_NAME" | wc -l) && return
    # ???
    # Profit!!
}

stop() {
    docker ps -q epflsti/blueboxnoc | xargs --no-run-if-empty docker kill
}

case "$1" in
    status)
        docker ps $DOCKER_IMAGE_NAME ;;
    start)
        start ;;
    stop)
        stop ;;
    restart)
        stop
        start ;;
esac
