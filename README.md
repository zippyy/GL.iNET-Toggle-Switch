# GL.iNet WDS / Router Toggle

Switch a **GL.iNet router** between **Router mode** and **WDS mode** using the physical side toggle.

This project targets **GL.iNet / OpenWrt firmware** with the programmable toggle switch support used on newer 4.x firmware, including the `/etc/gl-switch.d/` hook and `/etc/config/switch-button`.

The installer is **interactive** and designed to be launched with a **single one-line command** over SSH.

---

## Features

- Interactive installer
- Single-line install command
- Uses the hardware toggle switch
- Saves separate `Router` and `WDS` profiles
- Restores the selected profile automatically when the switch changes
- Persists files across firmware upgrades if you choose that option

---

## Prerequisites

- Root access on the router: `ssh root@<router-ip>`
- GL.iNet firmware with toggle-switch scripting support
- Internet access on the router for the one-line installer

---

## One-Line Install

SSH into the router as `root`, then run:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zippyy/GL.iNET-Toggle-Switch/main/install.sh)"
```

Or with `wget`:

```sh
sh -c "$(wget -O - https://raw.githubusercontent.com/zippyy/GL.iNET-Toggle-Switch/main/install.sh)"
```

The installer will:

1. Install the toggle-switch handler
2. Configure `/etc/config/switch-button`
3. Ask whether to keep the files across firmware upgrades
4. Let you save the current setup as `Router`, `WDS`, or walk through both

---

## Manual Install

If you do not want to use the one-liner, copy `install.sh` to the router and run:

```sh
sh /path/to/install.sh
```

The installer writes this switch script:

```sh
#!/bin/sh
[ "$1" = "on" ] && f=/root/wds-router-toggle/wds.tar.gz || f=/root/wds-router-toggle/router.tar.gz; [ -f "$f" ] || { logger -t wds-router-toggle "missing profile $f"; exit 1; }; logger -t wds-router-toggle "restoring $f"; sysupgrade -r "$f"; reboot
```

Meaning:

- switch `off` restores `router.tar.gz`
- switch `on` restores `wds.tar.gz`

---

## How It Works

This project uses a **profile-based** approach instead of trying to modify live network settings in place.

That matters because switching between **Router** and **WDS** typically changes multiple OpenWrt subsystems at once:

- network
- wireless
- firewall
- DNS / upstream routing

So instead of partially reconfiguring the device, the switch restores a complete saved profile and reboots cleanly.

---

## Test Without Using the Toggle

From SSH:

```sh
/etc/gl-switch.d/wds-router-toggle.sh off
```

After reboot, test WDS:

```sh
/etc/gl-switch.d/wds-router-toggle.sh on
```

---

## Installed Files

- `/etc/gl-switch.d/wds-router-toggle.sh`
- `/etc/config/switch-button`
- `/root/wds-router-toggle/router.tar.gz`
- `/root/wds-router-toggle/wds.tar.gz`

If you choose persistence during install, these paths are also added to:

```sh
/etc/sysupgrade.conf
```

---

## Notes

- Both saved profiles must come from the same router.
- Restoring either profile reboots the device.
- Save the `WDS` profile only after WDS is fully working.
- This is intended for GL.iNet firmware that supports custom toggle-switch scripts.
