# Changelog

## 0.2.0 (first public release)

Unofficial. Not affiliated with Neural DSP or Omarchy. Development builds were
numbered 0.1.0-N.

### Running Cortex Control
- **Runtime:** Cortex Control 4.1.0 runs through umu-launcher with a pinned,
  SHA-512-verified GE-Proton11-9 in its own Wine prefix. The system Wine isn't
  used or replaced.
- **QC connection:** enabled with `PROTON_ENABLE_HIDRAW` plus a udev rule
  limited to the Quad Cortex (`152a:880a`) and Quad Cortex mini (`152a:892f`).
- **Setup:** `cortex-control-setup` is per-user, can be re-run safely and
  checks the installer and app hashes. It offers Neural DSP's setup wizard or a
  silent install.
- **Online indicator:** the launcher feeds the PowerShell connectivity shim
  adapted from taylortek91/cortex-control-wine.

### Omarchy integration
- **Tiling:** two display modes. `gamescope` (the default when installed)
  letterboxes the app into any tile size. `window` pseudotiles it.
- **Show/hide:** `cortex-control --show/--hide/--toggle`, using a hidden
  special workspace. The app stays connected while hidden.
- **Keyboard shortcuts with OSD feedback:**
  - Super+Shift+Q: show or hide the editor
  - Super+Alt+Q: tuner
  - Super+Alt+N/P: next/previous scene
  - Super+Alt+M: mode
  - Super+Alt+B: tap tempo
  - Super+Ctrl+Alt+1–8: footswitches
- **Keys help:** `cortex-control --keys` (text, `--json`, `--menu`) reads the
  live bindings. Setup keeps your edited keys and writes newer defaults to
  `cortex-control.lua.new`.
- **Bar widget:** shown while Cortex Control runs, with show/hide, mode,
  scenes, footswitches, tuner, tap tempo, Pro Audio and volume, setup status
  and a Keys link.
- **Omarchy menu:** Trigger › Quad Cortex and Learn › Quad Cortex.

### Device control without the editor
- **`cortex-control-qc`:** the QC's documented incoming MIDI messages (scenes,
  modes, footswitches, tuner, tap tempo, Gig View, presets), plus PipeWire
  audio: the Pro Audio profile, volume and mute.

### Diagnostics
- **`cortex-control-doctor`:** read-only checks, with `--json`, and `--status`
  for the widget.

### Documentation
- **README:** with a disclaimer and a "What this changes on your system"
  section.
- **Supporting files:** THIRD-PARTY-NOTICES, COMPATIBILITY, CONTRIBUTING and
  issue templates.
