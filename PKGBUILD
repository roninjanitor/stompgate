# Maintainer: Nick Lozano
#
# Unofficial; not affiliated with Neural DSP or Omarchy.
#
# Runs Neural DSP Cortex Control on Omarchy with umu-launcher and a pinned
# GE-Proton in a per-user prefix. Neural DSP's installer and app are not
# included or modified; stompgate-setup installs the user's own copy.

pkgname=stompgate
pkgver=0.4.0
pkgrel=1
pkgdesc='Run Neural DSP Cortex Control (Quad Cortex editor) on Omarchy via umu-launcher and GE-Proton'
arch=('any')
url='https://github.com/roninjanitor/stompgate'
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
  'libx11'
  'lsof'
  'procps-ng'
  'python'
  'systemd'
  'tar'
  'umu-launcher'
  'xdg-user-dirs'
)
optdepends=(
  'gamescope: letterbox Cortex Control into any tile size without cropping'
  'gum: choose the install mode interactively'
  'vulkan-tools: let stompgate-doctor name the Vulkan GPU'
  'pipewire-jack: use the Quad Cortex as an audio interface in JACK apps such as REAPER'
)
# Renamed from cortex-control-omarchy (development builds); stompgate-setup
# migrates an existing per-user install.
conflicts=('cortex-control-omarchy')
replaces=('cortex-control-omarchy')
install="$pkgname.install"

# Built from this repository's working tree, so there is no source array.
package() {
  local share="$pkgdir/usr/share/$pkgname"
  cd "$startdir"

  install -Dm644 lib/stompgate.sh "$share/lib/stompgate.sh"
  install -Dm755 lib/x11-close.py "$share/lib/x11-close.py"
  for cmd in bin/*; do
    install -Dm755 "$cmd" "$pkgdir/usr/bin/${cmd#bin/}"
  done
  install -Dm644 shims/powershell.bat "$share/shims/powershell.bat"
  install -Dm644 hypr/stompgate.lua "$share/hypr/stompgate.lua"
  install -Dm644 menu/omarchy-menu.jsonc "$share/menu/omarchy-menu.jsonc"
  install -Dm644 plugin/manifest.json "$share/plugin/manifest.json"
  install -Dm644 plugin/Panel.qml "$share/plugin/Panel.qml"
  install -Dm644 udev/70-stompgate.rules "$pkgdir/usr/lib/udev/rules.d/70-stompgate.rules"
  install -Dm644 desktop/stompgate.desktop "$pkgdir/usr/share/applications/stompgate.desktop"
  install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  install -Dm644 THIRD-PARTY-NOTICES.md "$pkgdir/usr/share/licenses/$pkgname/THIRD-PARTY-NOTICES.md"
  install -Dm644 CHANGELOG.md "$pkgdir/usr/share/doc/$pkgname/CHANGELOG.md"
}
