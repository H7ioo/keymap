#!/usr/bin/env bash
# Start my keyboard layout on any x86-64 Linux PC (Pardus, Fedora, Ubuntu, ...).
#
#   curl -fsSL https://raw.githubusercontent.com/H7ioo/keymap/main/linux/run.sh | bash
#   ... | bash -s -- --undo     # put the keyboard back to normal
#
# With sudo: runs kanata, the full layout (tap Caps = Esc, hold = Ctrl, Caps+H = Backspace).
# Without sudo: falls back to "Caps = Ctrl". Ctrl+H is then Backspace in terminals and Neovim
# only, and Esc is Ctrl+[ (Vim treats it as Esc).
set -euo pipefail

KANATA_VERSION=v1.12.0
KANATA_ZIP_SHA256=0bedd91567c5d7c54679061baadc37e4f83fb71750003999bc1d11f2c9754f36
CONFIG_URL=https://raw.githubusercontent.com/H7ioo/keymap/main/kanata.kbd
CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/keymap
FALLBACK_OPTION=ctrl:nocaps
FALLBACK_LASTS=

say() { printf 'keymap: %s\n' "$*" >&2; }

can_sudo() {
  [[ $(id -u) -eq 0 ]] && return 0
  command -v sudo >/dev/null || return 1
  sudo -n true 2>/dev/null && return 0
  # Only prompt for a password if this account is an admin, so non-admins don't trigger
  # failed-sudo reports on a shared machine.
  id -nG | tr ' ' '\n' | grep -qxE 'sudo|wheel|admin' || return 1
  say "asking for your password to run kanata as root..."
  # Read the password from the terminal even when this script arrives through curl | bash.
  # shellcheck disable=SC2024
  sudo -v </dev/tty
}

as_root() { if [[ $(id -u) -eq 0 ]]; then "$@"; else sudo "$@"; fi; }

unzip_file() { # zip, member, destination dir
  if command -v unzip >/dev/null; then
    unzip -o -q "$1" "$2" -d "$3"
  else
    python3 -m zipfile -e "$1" "$3"
  fi
}

run_kanata() {
  [[ $(uname -m) == x86_64 ]] || { say "kanata release binaries are x86-64 only."; exit 1; }
  if systemctl is-active --quiet keyd 2>/dev/null; then
    say "keyd is already remapping this keyboard; not starting kanata on top of it."
    exit 1
  fi

  mkdir -p "$CACHE"
  local bin=$CACHE/kanata-$KANATA_VERSION
  if [[ ! -x $bin ]]; then
    say "downloading kanata $KANATA_VERSION..."
    curl -fsSL -o "$CACHE/kanata.zip" \
      "https://github.com/jtroo/kanata/releases/download/$KANATA_VERSION/linux-binaries-x64.zip"
    if ! echo "$KANATA_ZIP_SHA256  $CACHE/kanata.zip" | sha256sum -c --quiet; then
      rm -f "$CACHE/kanata.zip"
      say "kanata download does not match the expected checksum, not running it."
      exit 1
    fi
    unzip_file "$CACHE/kanata.zip" kanata_linux_x64 "$CACHE"
    mv "$CACHE/kanata_linux_x64" "$bin"
    chmod +x "$bin"
    rm -f "$CACHE"/kanata.zip "$CACHE"/kanata_linux_cmd_allowed_x64
  fi

  # Use the config next to this script when run from a clone, otherwise download it.
  local cfg=$CACHE/kanata.kbd src=${BASH_SOURCE[0]:-}
  if [[ -f $src && -f $(dirname "$src")/../kanata.kbd ]]; then
    cp "$(dirname "$src")/../kanata.kbd" "$cfg"
  else
    curl -fsSL -o "$cfg" "$CONFIG_URL"
  fi

  as_root modprobe uinput 2>/dev/null || true
  say "running. Tap Caps = Esc | hold Caps = Ctrl | Caps+H = Backspace"
  say "stop: Ctrl+C here, or press Left Ctrl + Space + Esc together."
  as_root "$bin" --cfg "$cfg" --quiet </dev/null
}

# --- Fallback without root: XKB option, which any user may set for their own session ---

gnome_wayland() {
  [[ ${XDG_SESSION_TYPE:-} == wayland ]] && command -v gsettings >/dev/null &&
    gsettings get org.gnome.desktop.input-sources xkb-options >/dev/null 2>&1
}

fallback() { # on|off
  if gnome_wayland; then
    local opts
    opts=$(gsettings get org.gnome.desktop.input-sources xkb-options | python3 -c '
import ast, sys
opts = [o for o in ast.literal_eval(sys.stdin.read().replace("@as ", "")) if o != sys.argv[2]]
if sys.argv[1] == "on":
    opts.append(sys.argv[2])
print(opts)' "$1" "$FALLBACK_OPTION")
    gsettings set org.gnome.desktop.input-sources xkb-options "$opts"
    FALLBACK_LASTS="until you run --undo (GNOME saves it)"
  elif [[ ${XDG_SESSION_TYPE:-x11} != wayland && -n ${DISPLAY:-} ]] && command -v setxkbmap >/dev/null; then
    local opts
    opts=$(setxkbmap -query | awk '/^options:/ {print $2}' | tr ',' '\n' | grep -vx "$FALLBACK_OPTION" | paste -sd, || true)
    [[ $1 == on ]] && opts=${opts:+$opts,}$FALLBACK_OPTION
    setxkbmap -option '' ${opts:+-option "$opts"}
    FALLBACK_LASTS="until you log out"
  else
    say "no X11 session or GNOME on Wayland found; set Caps Lock to Ctrl in your desktop's keyboard settings."
    exit 1
  fi
}

if [[ ${1:-} == --undo ]]; then
  if [[ $(id -u) -eq 0 ]] || sudo -n true 2>/dev/null; then
    as_root pkill -f "$CACHE/kanata-" || true
  fi
  fallback off 2>/dev/null || true
  say "keyboard back to normal."
elif can_sudo; then
  run_kanata
else
  fallback on
  say "no sudo here, so Caps Lock is now Ctrl ($FALLBACK_LASTS)."
  say "Caps+H = Backspace in terminals and Neovim, Caps+[ = Esc. Undo with --undo."
fi
