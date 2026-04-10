#!/bin/sh
[ "$1" = "on" ] && f=/root/wds-router-toggle/wds.tar.gz || f=/root/wds-router-toggle/router.tar.gz; [ -f "$f" ] || { logger -t wds-router-toggle "missing profile $f"; exit 1; }; logger -t wds-router-toggle "restoring $f"; sysupgrade -r "$f"; reboot
