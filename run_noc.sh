#!/bin/sh

# Start or stop the Docker image for blueboxnoc
#
# Can be used / installed as a SysV startup script

: ${BLUEBOXNOC_DOCKER_NAME:="epflsti/blueboxnoc"}

start() {
    test 0 '!=' $(docker ps -q "$BLUEBOXNOC_DOCKER_NAME" | wc -l) && return
    # ???
    # Profit!!
}

stop() {
    docker ps -q epflsti/blueboxnoc | xargs --no-run-if-empty docker kill
}

case "$1" in
    status)
        docker ps $BLUEBOXNOC_DOCKER_NAME ;;
    start)
        start ;;
    stop)
        stop ;;
    restart)
        stop
        start ;;
esac
