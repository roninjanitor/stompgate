# Shared settings and helpers for the cortex-control-* commands. Sourced, not run.

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
HIDDEN_WORKSPACE="special:cortex-control"
CLOUD_CHECK_URL="https://cloud.neuraldsp.com/"

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/cortex-control-omarchy"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/cortex-control-omarchy"
PREFIX="${CORTEX_CONTROL_PREFIX:-$DATA_DIR/prefix}"
PROTON_DIR="$DATA_DIR/proton/$PROTON_VERSION-x86_64"
APP_DIR="$PREFIX/drive_c/Program Files/Neural DSP/Cortex Control"
APP="$APP_DIR/Cortex Control.exe"
HYPR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
HYPR_RULE_FILE="$HYPR_DIR/cortex-control.lua"
HYPR_REQUIRE_LINE='require("default.hypr.require_optional").module("hypr.cortex-control")'
PLUGIN_ID="cortex-control-omarchy.quad-cortex"
PLUGIN_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/$PLUGIN_ID"
ICON_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor"

# Static files: the checkout when run from it, otherwise the installed package.
if [[ -z ${SHARE_DIR:-} ]]; then
  _cc_lib_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  if [[ -f $_cc_lib_dir/../PKGBUILD ]]; then
    SHARE_DIR="$(realpath "$_cc_lib_dir/..")"
  else
    SHARE_DIR="/usr/share/cortex-control-omarchy"
  fi
  unset _cc_lib_dir
fi

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
