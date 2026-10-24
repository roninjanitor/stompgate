# Changelog

## 0.3.0

### Added
- **Quit Cortex Control:** `stompgate --quit`, a **Quit** button (`q`) in the
  bar widget and **Quit Cortex Control** in the Omarchy menu, so the editor can
  be closed while it's hidden. It asks the editor to close as its close button
  would. In gamescope mode that request goes to the app on gamescope's own X
  display (closing the gamescope window would kill the app outright), through a
  small Python/libX11 helper. Wine's `taskkill` isn't used: it also closes
  Wine's hidden IME windows, after which Cortex Control ignores the request.
  `stompgate --quit --force` ends the Wine session of an editor that's stuck.
- **Startup feedback:** "Starting editor…" stays on Omarchy's
  on-screen display until the window appears, and a notification says so if
  the app exits first or never shows its window. Pressing the shortcut again
  meanwhile repeats the message instead of reporting an error, and no longer
  risks starting a second copy before the first one's process shows up.

### Fixed
- **Editor invisible in gamescope mode:** with gamescope 3.16.31 or later on
  Hyprland 0.56.2 the editor started but its window never appeared, and later
  presses of the shortcut reported that it was already starting. Gamescope
  hides its window for a moment while Proton starts and then waits for the
  configure that xdg-shell requires; Hyprland up to 0.56.2 never sends it after
  an unmap (fixed upstream in hyprwm/Hyprland#16444, not yet released). The
  launcher now detects that pair, opens a normal window instead and says so.
  `stompgate-doctor` reports it and shows the fix: keep gamescope 3.16.28
  (`IgnorePkg = gamescope`) until Hyprland updates. Gamescope's SDL backend was
  tried and rejected: it crashes in `vulkan_remake_swapchain` on NVIDIA.
  Tracked in #1.

## 0.2.0 (first public release)

Unofficial. Not affiliated with Neural DSP or Omarchy. Development builds were
called cortex-control-omarchy 0.1.0-N. The project was renamed **Stompgate** so
its name doesn't borrow Neural DSP's "Cortex" branding. `stompgate-setup` moves
an existing install to the new names, and the new package replaces the old one.

### Running Cortex Control
- **Runtime:** Cortex Control 4.1.0 runs through umu-launcher with a pinned,
  SHA-512-verified GE-Proton11-9 in its own Wine prefix. The system Wine isn't
  used or replaced.
- **QC connection:** enabled with `PROTON_ENABLE_HIDRAW` plus a udev rule
  limited to the Quad Cortex (`152a:880a`) and Quad Cortex mini (`152a:892f`).
- **Setup:** `stompgate-setup` is per-user, can be re-run safely and
  checks the installer and app hashes. It offers Neural DSP's setup wizard or a
  silent install.
- **Online indicator:** the launcher feeds the PowerShell connectivity shim
  adapted from taylortek91/cortex-control-wine.

### Omarchy integration
- **Tiling:** two display modes. `gamescope` (the default when installed)
  letterboxes the app into any tile size. `window` pseudotiles it.
- **Show/hide:** `stompgate --show/--hide/--toggle`, using a hidden
  special workspace. The app stays connected while hidden.
- **Keyboard shortcuts with OSD feedback:**
  - Super+Shift+Q: show or hide the editor
  - Super+Alt+Q: tuner
  - Super+Alt+N/P: next/previous scene
  - Super+Alt+M: mode
  - Super+Alt+B: tap tempo
  - Super+Ctrl+Alt+1–8: footswitches
- **Keys help:** `stompgate --keys` (text, `--json`, `--menu`) reads the
  live bindings. Setup keeps your edited keys and writes newer defaults to
  `stompgate.lua.new`.
- **Bar widget:** shown while Cortex Control runs, with show/hide, mode,
  scenes, footswitches, tuner, tap tempo, Pro Audio and volume, setup status
  and a Keys link.
- **Omarchy menu:** Trigger › Stompgate and Learn › Stompgate.

### Device control without the editor
- **`stompgate-qc`:** the QC's documented incoming MIDI messages (scenes,
  modes, footswitches, tuner, tap tempo, Gig View, presets), plus PipeWire
  audio: the Pro Audio profile, volume and mute.

### Diagnostics
- **`stompgate-doctor`:** read-only checks, with `--json`, and `--status`
  for the widget.

### Documentation
- **README:** with a disclaimer and a "What this changes on your system"
  section.
- **Supporting files:** THIRD-PARTY-NOTICES, COMPATIBILITY, CONTRIBUTING and
  issue templates.
