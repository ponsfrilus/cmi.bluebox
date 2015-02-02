#!/bin/sh

set -e -x

which puppet || {
    echo >&2 Please install puppet first.
    exit 1
}
