#!/bin/sh

# Start or stop the Docker image for blueboxnoc
#
# Can be used / installed as a SysV startup script

: ${BLUEBOXNOC_DOCKER_NAME:="epflsti/blueboxnoc"}
: ${BLUEBOXNOC_VAR_DIR:="/srv/blueboxnoc"}
: ${BLUEBOXNOC_CODE_DIR:="."}


start() {
    test 0 '!=' $(docker ps -q "$BLUEBOXNOC_DOCKER_NAME" | wc -l) && return
    docker run --net=host --device=/dev/net/tun -d \
           -v "$BLUEBOXNOC_VAR_DIR":/srv \
           -v "$BLUEBOXNOC_CODE_DIR":/opt/blueboxnoc \
           "$BLUEBOXNOC_DOCKER_NAME" \
           node /opt/blueboxnoc/blueboxnoc-ui/helloworld.js # XXX Must start tinc too
    # Profit!!
}

stop() {
    docker ps -q $BLUEBOXNOC_DOCKER_NAME | xargs --no-run-if-empty docker kill
}

case "$1" in
    status)
        docker ps $BLUEBOXNOC_DOCKER_NAME ;;
    start)
        start ;;
    stop)
        stop ;;
    shell)
        docker exec -it $(docker ps -q $BLUEBOXNOC_DOCKER_NAME) bash ;;
    restart)
        stop
        start ;;
esac
