# GL.iNet WDS / Router Toggle

This repo now installs through a single interactive script that:

- writes the GL.iNet switch handler
- configures `/etc/config/switch-button`
- optionally adds persistence entries to `/etc/sysupgrade.conf`
- lets you save the current config as `router`, `wds`, or walk through both

## One-line install

From the router over SSH as `root`, run one of these:

If the repo is local on the router:

```sh
sh /path/to/install.sh
```

If you host this repo on GitHub, the typical one-liner is:

```sh
sh -c "$(wget -O - https://raw.githubusercontent.com/<owner>/<repo>/<branch>/install.sh)"
```

or:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/<branch>/install.sh)"
```

## What the installer does

It installs this switch script on the router:

```sh
#!/bin/sh
[ "$1" = "on" ] && f=/root/wds-router-toggle/wds.tar.gz || f=/root/wds-router-toggle/router.tar.gz; [ -f "$f" ] || { logger -t wds-router-toggle "missing profile $f"; exit 1; }; logger -t wds-router-toggle "restoring $f"; sysupgrade -r "$f"; reboot
```

Meaning:

- switch `off` restores `router.tar.gz`
- switch `on` restores `wds.tar.gz`

## Notes

- This is profile-based because Router mode and WDS mode usually change multiple OpenWrt subsystems, not one toggle.
- Both saved profiles must come from the same router.
- Restoring a profile reboots the device.
