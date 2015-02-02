#!/bin/sh

set -e -x

which puppet || {
    echo >&2 Please install puppet first.
    exit 1
}

: ${CHECKOUT_DIR:="${dirname "$0"}"}
: ${PUPPET_MODULES_DIR:=/etc/puppet/environments/production/modules}

ln -sf "${CHECKOUT_DIR}"/noc/puppet/modules/blueboxnoc "$PUPPET_MODULES_DIR"/
