# Shared settings and helpers for the stompgate commands. Sourced, not run.

# Pinned inputs. Change these together and retest before bumping.
CC_VERSION="4.1.0"
CC_INSTALLER_SHA256="c03942a0631afd195d3d70febf91384bf39cb7101014146f26f5ba65fd73228c"
CC_APP_SHA256="9be548fb6cbd2e8c80715015c2a2f0f248c9b01a7165004e2b017ffe2b14e65a"
# Neural DSP's own download link for the official installer (not mirrored here).
CC_INSTALLER_URL="https://downloads.neuraldsp.com/file/cortex-control-installers/v_$CC_VERSION/windows/Cortex%20Control%20v$CC_VERSION.exe"
CC_INSTALLER_NAME="Cortex Control v$CC_VERSION.exe"
PROTON_VERSION="GE-Proton11-9"
PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$PROTON_VERSION/$PROTON_VERSION-x86_64.tar.gz"
PROTON_SHA512="30160946a5e4ffdf1f29d6f83a3d27108f6aa71b6aa59095b2c2260fe3a003b62acf8fdcb02a3dfc602b28473f5679d8a3eaee5a8adb141c1dfa01c42888da2d"

# Quad Cortex (152a:880a) and Quad Cortex mini (152a:892f). Nothing else.
QC_USB_IDS=("152a:880a" "152a:892f")
QC_PROTON_HIDRAW="0x152A/0x880A,0x152A/0x892F"

GAMEID="umu-cortexcontrol"
WINDOW_CLASS="steam_app_cortexcontrol"
# jq filter for the Cortex Control window: the app's own XWayland window, or
# the gamescope window it runs inside (titled after the app).
WINDOW_JQ='select(.class == "steam_app_cortexcontrol" or (.class == "gamescope" and (.title | startswith("Cortex Control"))))'
APP_MIN_WIDTH=800  # below about 800x570 the app crops its own UI
APP_RATIO="1.404"
HIDDEN_WORKSPACE="special:stompgate"
CLOUD_CHECK_URL="https://cloud.neuraldsp.com/"

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/stompgate"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/stompgate"
PREFIX="${STOMPGATE_PREFIX:-$DATA_DIR/prefix}"
PROTON_DIR="$DATA_DIR/proton/$PROTON_VERSION-x86_64"
APP_DIR="$PREFIX/drive_c/Program Files/Neural DSP/Cortex Control"
APP="$APP_DIR/Cortex Control.exe"
HYPR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
HYPR_RULE_FILE="$HYPR_DIR/stompgate.lua"
HYPR_REQUIRE_LINE='require("default.hypr.require_optional").module("hypr.stompgate")'
PLUGIN_ID="stompgate.widget"
PLUGIN_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/$PLUGIN_ID"
MENU_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/extensions/omarchy-menu.jsonc"
MENU_BEGIN="// >>> stompgate"
MENU_END="// <<< stompgate"
ICON_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor"

# How the window is shown. gamescope: inside gamescope, which letterboxes the
# app into any tile size. window: a normal window, pseudotiled by the Hyprland
# rule. Set with stompgate-setup --display, or STOMPGATE_DISPLAY.
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/stompgate/config"
display_mode() {
  local mode="${STOMPGATE_DISPLAY:-}"
  [[ -n $mode ]] || mode=$(sed -n 's/^display=//p' "$CONFIG_FILE" 2>/dev/null | tail -1)
  if [[ -z $mode ]]; then
    command -v gamescope >/dev/null && mode="gamescope" || mode="window"
  fi
  [[ $mode == gamescope ]] && ! command -v gamescope >/dev/null && mode="window"
  echo "$mode"
}

# Static files: the checkout when run from it, otherwise the installed package.
if [[ -z ${SHARE_DIR:-} ]]; then
  _cc_lib_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  if [[ -f $_cc_lib_dir/../PKGBUILD ]]; then
    SHARE_DIR="$(realpath "$_cc_lib_dir/..")"
  else
    SHARE_DIR="/usr/share/stompgate"
  fi
  unset _cc_lib_dir
fi

# The widget is these two files; the repo's plugin/ folder also holds a README
# and LICENSE for publishing it on its own, which aren't installed.
PLUGIN_FILES=(manifest.json Panel.qml)

# True when the installed widget matches the given source folder.
plugin_current() {
  local src="$1" f
  for f in "${PLUGIN_FILES[@]}"; do
    cmp -s "$src/$f" "$PLUGIN_DIR/$f" || return 1
  done
}

# Remove a marked block (ours by default) from Omarchy's menu extensions file.
remove_menu_block() {
  local begin="${1:-$MENU_BEGIN}" end="${2:-$MENU_END}"
  [[ -f $MENU_FILE ]] && grep -qF "$begin" "$MENU_FILE" || return 0
  awk -v b="$begin" -v e="$end" 'index($0, b) { skip = 1 } !skip { print } index($0, e) { skip = 0 }' \
    "$MENU_FILE" >"$MENU_FILE.tmp" && mv "$MENU_FILE.tmp" "$MENU_FILE"
}

# Development builds were called cortex-control-omarchy. stompgate-setup moves
# such an install over; the doctor warns while any of it is left.
OLD_NAME="cortex-control-omarchy"
OLD_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/$OLD_NAME"
OLD_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/$OLD_NAME"
OLD_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/$OLD_NAME"
OLD_HYPR_RULE_FILE="$HYPR_DIR/cortex-control.lua"
OLD_HYPR_REQUIRE_LINE='require("default.hypr.require_optional").module("hypr.cortex-control")'
OLD_PLUGIN_ID="$OLD_NAME.quad-cortex"
OLD_PLUGIN_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/$OLD_PLUGIN_ID"
OLD_MENU_BEGIN="// >>> $OLD_NAME"
OLD_MENU_END="// <<< $OLD_NAME"

# Print what's left of an old-name install, one item per line.
old_install_leftovers() {
  [[ -d $OLD_DATA_DIR ]] && echo "$OLD_DATA_DIR"
  [[ -d $OLD_STATE_DIR ]] && echo "$OLD_STATE_DIR"
  [[ -d $OLD_CONFIG_DIR ]] && echo "$OLD_CONFIG_DIR"
  [[ -f $OLD_HYPR_RULE_FILE ]] && echo "$OLD_HYPR_RULE_FILE"
  grep -qF "$OLD_HYPR_REQUIRE_LINE" "$HYPR_DIR/hyprland.lua" 2>/dev/null && echo "$HYPR_DIR/hyprland.lua (old require line)"
  [[ -d $OLD_PLUGIN_DIR ]] && echo "$OLD_PLUGIN_DIR"
  grep -qF "$OLD_MENU_BEGIN" "$MENU_FILE" 2>/dev/null && echo "$MENU_FILE (old menu entries)"
  compgen -G "$ICON_DIR/*/apps/cortex-control.png" >/dev/null && echo "$ICON_DIR/*/apps/cortex-control.png"
  return 0
}

info() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die() {
  printf '\033[1;31mError:\033[0m %s\n' "$*" >&2
  exit 1
}

# Show a desktop notification when not attached to a terminal (e.g. launched
# from the app launcher), otherwise print to stderr.
notify() {
  if [[ -t 2 ]]; then
    printf '%s\n' "$*" >&2
  else
    notify-send -a "Cortex Control" "Cortex Control" "$*" 2>/dev/null || true
  fi
}

refuse_root() {
  (( EUID != 0 )) || die "run this as your normal user, not root."
}

app_running() {
  pgrep -f '[C]ortex Control\.exe' >/dev/null
}

# Print "<node> <vid:pid> <name>" for each connected Quad Cortex HID node.
qc_hidraw_nodes() {
  local sys uevent id name vidpid qc
  for sys in /sys/class/hidraw/hidraw*; do
    uevent="$sys/device/uevent"
    [[ -r $uevent ]] || continue
    id=$(sed -n 's/^HID_ID=//p' "$uevent")
    name=$(sed -n 's/^HID_NAME=//p' "$uevent")
    # HID_ID looks like 0003:0000152A:0000892F
    vidpid=$(awk -F: '{ printf "%s:%s", tolower(substr($2, 5)), tolower(substr($3, 5)) }' <<<"$id")
    for qc in "${QC_USB_IDS[@]}"; do
      if [[ $vidpid == "$qc" ]]; then
        echo "/dev/${sys##*/} $vidpid $name"
      fi
    done
  done
  return 0
}

# Run a program in the prefix through umu with the pinned Proton.
umu() {
  WINEPREFIX="$PREFIX" PROTONPATH="$PROTON_DIR" GAMEID="$GAMEID" umu-run "$@"
}
