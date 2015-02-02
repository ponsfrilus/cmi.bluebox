#!/bin/sh

set -e -x

which puppet || {
    echo >&2 Please install puppet first.
    exit 1
}

: ${CHECKOUT_DIR:="$(dirname "$0")"}
case "$CHECKOUT_DIR" in
    .|./*)
        CHECKOUT_DIR="$PWD/$CHECKOUT_DIR";;
esac

: ${PUPPET_MODULES_DIR:="$(puppet agent --configprint modulepath | cut -d: -f1)"}

ln -sf "${CHECKOUT_DIR}"/noc/puppet/modules/blueboxnoc "$PUPPET_MODULES_DIR"/
