# GL.iNet WDS / Router Toggle Switch

This repo contains a GL.iNet router-side script that makes the physical toggle switch select between:

- `off` -> normal `Router` mode
- `on` -> `WDS` mode

The implementation is intentionally profile-based. Instead of trying to reconfigure every network, firewall, DNS, and wireless setting in place, the switch restores one of two saved OpenWrt config backups and then reboots.

That makes it much more reliable across GL.iNet models and firmware variants.

## Firmware support

The included switch integration targets GL.iNet firmware `4.8.0+`, which uses:

- `/etc/gl-switch.d/<name>.sh`
- `/etc/config/switch-button`

If you are on an older 4.x build, the same backup/restore approach still works, but the hook for the hardware switch may be different on your device.

## Files

- `router/wds-router-toggle.sh`: one-line switch handler for the router
- `router/capture-profile.sh`: optional helper to save the current config as a named profile
- `router/switch-button`: example GL.iNet switch config

## How it works

1. Put the router in the exact `Router` configuration you want.
2. Save that config as a backup profile named `router`.
3. Put the router in the exact `WDS` configuration you want.
4. Save that config as a backup profile named `wds`.
5. Install the switch script.
6. Flip the hardware switch:
   - `off` restores the `router` profile
   - `on` restores the `wds` profile

Each switch event restores the matching backup archive and reboots the router.

## Install

SSH to the router as `root`, then copy the files in this repo to the router:

```sh
mkdir -p /etc/gl-switch.d /root/wds-router-toggle
```

Copy:

- `router/wds-router-toggle.sh` -> `/etc/gl-switch.d/wds-router-toggle.sh`
- `router/switch-button` -> `/etc/config/switch-button`

Make the scripts executable:

```sh
chmod +x /etc/gl-switch.d/wds-router-toggle.sh
```

## Capture the two profiles

First, configure the router exactly how you want in normal router mode, then run:

```sh
mkdir -p /root/wds-router-toggle && sysupgrade -b /root/wds-router-toggle/router.tar.gz
```

Then change the router to the exact WDS setup you want and run:

```sh
sysupgrade -b /root/wds-router-toggle/wds.tar.gz
```

This creates:

- `/root/wds-router-toggle/router.tar.gz`
- `/root/wds-router-toggle/wds.tar.gz`

## Preserve files across firmware upgrades

Add these paths to `/etc/sysupgrade.conf`:

```sh
/etc/gl-switch.d/wds-router-toggle.sh
/etc/config/switch-button
/root/wds-router-toggle/
```

You can append them with:

```sh
cat >> /etc/sysupgrade.conf <<'EOF'
/etc/gl-switch.d/wds-router-toggle.sh
/etc/config/switch-button
/root/wds-router-toggle/
EOF
```

## Test manually before using the switch

Test the script from SSH first:

```sh
/etc/gl-switch.d/wds-router-toggle.sh off
```

After the router comes back, test:

```sh
/etc/gl-switch.d/wds-router-toggle.sh on
```

If both profiles restore cleanly, the hardware switch should behave the same way.

## Notes

- The script does a full config restore and reboot by design.
- Make sure both saved profiles are created on the same router and firmware family.
- If your WDS setup depends on a nearby upstream AP, save the WDS profile only after it is fully working.
- The helper script is optional; the two `sysupgrade -b` commands above are enough if you want to keep this setup minimal.
