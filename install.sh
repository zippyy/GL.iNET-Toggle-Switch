#!/bin/sh

set -eu

SCRIPT_NAME="wds-router-toggle"
BASE_DIR="/root/wds-router-toggle"
SWITCH_SCRIPT="/etc/gl-switch.d/${SCRIPT_NAME}.sh"
SWITCH_CONFIG="/etc/config/switch-button"
SYSUPGRADE_CONF="/etc/sysupgrade.conf"
ROUTER_PROFILE="${BASE_DIR}/router.tar.gz"
WDS_PROFILE="${BASE_DIR}/wds.tar.gz"

need_root() {
    [ "$(id -u)" -eq 0 ] || { echo "Run this installer as root." >&2; exit 1; }
}

say() {
    printf '%s\n' "$*"
}

ask() {
    prompt="$1"
    default="${2:-}"
    if [ -n "$default" ]; then
        printf "%s [%s]: " "$prompt" "$default" >&2
    else
        printf "%s: " "$prompt" >&2
    fi
    IFS= read -r answer || true
    if [ -z "$answer" ]; then
        answer="$default"
    fi
    printf '%s' "$answer"
}

confirm() {
    prompt="$1"
    default="${2:-y}"
    answer="$(ask "$prompt (y/n)" "$default")"
    case "$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')" in
        y|yes) return 0 ;;
        *) return 1 ;;
    esac
}

save_profile() {
    name="$1"
    target="$BASE_DIR/$name.tar.gz"
    say ""
    say "Saving current router configuration as '$name'..."
    mkdir -p "$BASE_DIR"
    umask 077
    sysupgrade -b "$target"
    say "Saved $target"
}

append_unique_line() {
    file="$1"
    line="$2"
    grep -Fqx "$line" "$file" 2>/dev/null || printf '%s\n' "$line" >> "$file"
}

write_switch_script() {
    mkdir -p /etc/gl-switch.d
    cat > "$SWITCH_SCRIPT" <<'EOF'
#!/bin/sh
[ "$1" = "on" ] && f=/root/wds-router-toggle/wds.tar.gz || f=/root/wds-router-toggle/router.tar.gz; [ -f "$f" ] || { logger -t wds-router-toggle "missing profile $f"; exit 1; }; logger -t wds-router-toggle "restoring $f"; sysupgrade -r "$f"; reboot
EOF
    chmod 755 "$SWITCH_SCRIPT"
}

write_switch_config() {
    cat > "$SWITCH_CONFIG" <<'EOF'
config main
    option func 'wds-router-toggle'
EOF
}

main() {
    need_root

    say "GL.iNet WDS / Router Toggle installer"
    say "Switch off => Router profile"
    say "Switch on  => WDS profile"

    write_switch_script
    write_switch_config
    mkdir -p "$BASE_DIR"

    if confirm "Keep the switch files across firmware upgrades" "y"; then
        append_unique_line "$SYSUPGRADE_CONF" "$SWITCH_SCRIPT"
        append_unique_line "$SYSUPGRADE_CONF" "$SWITCH_CONFIG"
        append_unique_line "$SYSUPGRADE_CONF" "$BASE_DIR/"
    fi

    say ""
    say "Choose what to save:"
    say "1. Save current config as Router profile"
    say "2. Save current config as WDS profile"
    say "3. Guided setup for both profiles"
    say "4. Install switch only"
    choice="$(ask "Selection" "3")"

    case "$choice" in
        1)
            save_profile router
            ;;
        2)
            save_profile wds
            ;;
        3)
            say ""
            say "Step 1: set the router exactly how you want normal Router mode."
            confirm "Press y when the current config is ready to save as Router" "y" || exit 1
            save_profile router
            say ""
            say "Step 2: change the router in the web UI so WDS is fully working."
            confirm "Press y when the current config is ready to save as WDS" "y" || exit 1
            save_profile wds
            ;;
        4)
            ;;
        *)
            say "Invalid selection."
            exit 1
            ;;
    esac

    say ""
    say "Installed:"
    say "  $SWITCH_SCRIPT"
    say "  $SWITCH_CONFIG"
    say ""
    say "Profiles:"
    [ -f "$ROUTER_PROFILE" ] && say "  Router: $ROUTER_PROFILE" || say "  Router: not saved yet"
    [ -f "$WDS_PROFILE" ] && say "  WDS:    $WDS_PROFILE" || say "  WDS:    not saved yet"
    say ""
    say "Manual test:"
    say "  $SWITCH_SCRIPT off"
    say "  $SWITCH_SCRIPT on"
}

main "$@"
