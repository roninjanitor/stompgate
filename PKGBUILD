# Maintainer: Nick Lozano
#
# Runs Neural DSP Cortex Control on Omarchy with umu-launcher and a pinned
# GE-Proton in a per-user prefix. Neural DSP's installer and app are not
# included or modified; cortex-control-setup installs the user's own copy.

pkgname=cortex-control-omarchy
pkgver=0.1.0
pkgrel=12
pkgdesc='Run Neural DSP Cortex Control (Quad Cortex editor) on Omarchy via umu-launcher and GE-Proton'
arch=('any')
license=('MIT')
depends=(
  'alsa-utils'
  'bash'
  'coreutils'
  'curl'
  'gzip'
  'hyprland'
  'icoutils'
  'jq'
  'libnotify'
  'libpulse'
  'lsof'
  'procps-ng'
  'systemd'
  'tar'
  'umu-launcher'
  'xdg-user-dirs'
)
optdepends=(
  'gum: choose the install mode interactively'
  'vulkan-tools: let cortex-control-doctor name the Vulkan GPU'
  'pipewire-jack: use the Quad Cortex as an audio interface in JACK apps such as REAPER'
)
install="$pkgname.install"

# Built from this repository's working tree, so there is no source array.
package() {
  local share="$pkgdir/usr/share/$pkgname"
  cd "$startdir"

  install -Dm644 lib/cortex-control-omarchy.sh "$share/lib/cortex-control-omarchy.sh"
  for cmd in bin/*; do
    install -Dm755 "$cmd" "$pkgdir/usr/bin/${cmd#bin/}"
  done
  install -Dm644 shims/powershell.bat "$share/shims/powershell.bat"
  install -Dm644 hypr/cortex-control.lua "$share/hypr/cortex-control.lua"
  install -Dm644 menu/omarchy-menu.jsonc "$share/menu/omarchy-menu.jsonc"
  install -Dm644 plugin/manifest.json "$share/plugin/manifest.json"
  install -Dm644 plugin/Panel.qml "$share/plugin/Panel.qml"
  install -Dm644 udev/70-cortex-control-omarchy.rules "$pkgdir/usr/lib/udev/rules.d/70-cortex-control-omarchy.rules"
  install -Dm644 desktop/cortex-control.desktop "$pkgdir/usr/share/applications/cortex-control.desktop"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
