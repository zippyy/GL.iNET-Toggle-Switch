#!/bin/sh

set -eu

PROFILE_DIR="/root/wds-router-toggle"
profile="${1:-}"

case "$profile" in
    router|wds)
        ;;
    *)
        echo "Usage: $0 [router|wds]" >&2
        exit 1
        ;;
esac

mkdir -p "$PROFILE_DIR"
archive="$PROFILE_DIR/$profile.tar.gz"

umask 077
sysupgrade -b "$archive"

echo "Saved $profile profile to $archive"
