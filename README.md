# Stompgate

**Stompgate** runs Neural DSP's **Cortex Control**, the Windows editor for the
Quad Cortex, on [Omarchy](https://omarchy.org). *Unofficial; not affiliated
with Neural DSP or Omarchy.*

Stompgate is the name of this community project, not of a Neural DSP product. It runs through Proton, and the Quad Cortex
connects over USB, so you don't need a Windows VM. It also integrates with
Omarchy:

- **App launcher:** Cortex Control has its own entry, opened with Super + Space.
- **Tiling:** the editor tiles like any other window at any tile size, on any
  screen, without its UI getting cut off.
- **Bar widget:** shows the QC's status and gives quick controls.
- **Keyboard shortcuts:** show or hide the editor, toggle the tuner, and switch
  scenes and modes, with feedback on Omarchy's on-screen display.
- **Omarchy menu:** Stompgate entries under Trigger and Learn.
- **Doctor:** `stompgate-doctor` checks the whole setup.

> [!CAUTION]
> **Never update the Quad Cortex's firmware through Cortex Control on Linux.**
> If an update fails partway, the unit can be left unusable. Update firmware
> **over Wi‑Fi on the Quad Cortex itself**. **Back up your Quad Cortex before
> editing presets.**

## Disclaimer

**This is an unofficial community project.**

- **Not Neural DSP's:** it isn't affiliated with, endorsed by or supported by
  **Neural DSP Technologies**. Neural DSP doesn't support running Cortex Control
  on Linux and may decline to help with problems caused by it. Don't contact
  their support about this project.
- **Not part of Omarchy:** it isn't affiliated with or endorsed by **Omarchy**
  or its maintainers. It plugs into Omarchy's public extension points.
- **No warranty:** it's provided **as is**, without warranty of any kind (see
  [LICENSE](LICENSE)). You use it **at your own risk**. The authors aren't
  responsible for damaged or unusable ("bricked") devices, failed firmware
  updates, lost presets or other data, voided warranties, or any other damage.
  Neural DSP's hardware warranty excludes damage from not following the
  owner's manual, and using unsupported software may put it at risk.
- **No Neural DSP software:** this repository doesn't include, redistribute or
  modify any. Setup installs **your own copy** of the official installer, checks
  it by hash, and you accept **Neural DSP's license** as usual.
- **Trademarks:** Neural DSP, Quad Cortex, Quad Cortex mini and Cortex Control
  are trademarks of Neural DSP Technologies Oy. They're used here only to say
  what this project works with.

## Requirements

- **Omarchy** (Arch + Hyprland) with XWayland, which Omarchy enables by default.
- **A GPU with a Vulkan driver.** The editor draws through DXVK. Omarchy
  installs the NVIDIA, AMD or Intel Vulkan driver for your card.
- **A Quad Cortex or Quad Cortex mini**, connected with a USB **data** cable.
- **The official Cortex Control 4.1.0 Windows installer** from
  [neuraldsp.com/downloads](https://neuraldsp.com/downloads). If it isn't in
  `~/Downloads`, setup downloads it from Neural DSP.
- **About 2 GB of disk space** for the pinned GE-Proton, umu's Steam runtime
  and the Wine prefix.
- **Recommended: `gamescope`** (`sudo pacman -S gamescope`). It lets Cortex
  Control tile at any size without being cut off. See
  [Tiling and window size](#tiling-and-window-size).

## Install

```sh
git clone https://github.com/roninjanitor/stompgate.git ~/projects/stompgate
cd ~/projects/stompgate
makepkg -si                 # builds and installs the package (asks for sudo)
stompgate-setup        # per-user setup, run as yourself (no sudo)
omarchy restart shell       # loads the bar widget
```

**The package** installs the system parts:
- the `stompgate*` commands,
- the menu entry,
- a udev rule that lets you, the logged-in user, reach the QC's USB control
  interface. It matches **only** `152a:880a` (Quad Cortex) and `152a:892f`
  (Quad Cortex mini).

It depends on `umu-launcher` and doesn't install or replace the system Wine.

**`stompgate-setup`** does everything else, in your home folder. Each step
can be run again safely.
1. Downloads **GE-Proton11-9** and checks it against a pinned SHA-512.
2. Creates a dedicated Wine prefix in `~/.local/share/stompgate/`.
3. Checks the installer against the known SHA-256 for 4.1.0, then installs
   Cortex Control. You choose Neural DSP's setup wizard (shows the license) or a
   silent install (only if you've already accepted the license).
4. Extracts the app icon from your installed copy.
5. Adds the Hyprland window rule and keyboard shortcuts, the bar widget and the
   Omarchy menu entries. Skip any of these with `--no-hypr`, `--no-plugin` or
   `--no-menu`.
6. Picks the display mode: `gamescope` if it's installed, otherwise `window`.
   Change it later with `stompgate-setup --display gamescope|window`.

**On the Quad Cortex**, for the scene, tuner, mode and footswitch controls:
1. Go to **Settings → Device → MIDI**.
2. Turn on **MIDI OVER USB**.
3. Set **MIDI CHANNEL** to **1**, or to **OMNI**.

## What this changes on your system

Read this before you install.

**Needs sudo (asked for by `makepkg -si`, through pacman):**
- **Installs the package**, which owns these files:
  - `/usr/bin/stompgate*`
  - `/usr/share/stompgate/`
  - `/usr/share/applications/stompgate.desktop`
  - `/usr/lib/udev/rules.d/70-stompgate.rules`
  - the README and license under `/usr/share/doc` and `/usr/share/licenses`
- **Installs dependencies** from the Arch repos, including `umu-launcher`.
- **Installs the udev rule and reloads udev.** It gives the logged-in user
  access to the Quad Cortex's HID node (`152a:880a`, `152a:892f`) and **nothing
  else**.

**Your home folder (`stompgate-setup`, no sudo):**

| Path | What |
|---|---|
| `~/.local/share/stompgate/` | Pinned GE-Proton and the Wine prefix with Cortex Control |
| `~/.local/share/umu/` | umu-launcher's Steam runtime, shared with other umu apps |
| `~/.local/state/stompgate/` | Launcher log, MIDI send log, last scene/mode/tuner state |
| `~/.local/share/icons/hicolor/*/apps/stompgate-cortex-control.png` | App icon, extracted from your installed copy |
| `~/.config/hypr/stompgate.lua` | Window rule and keyboard shortcuts |
| `~/.config/hypr/hyprland.lua` | **One line added** to load the file above (backed up first) |
| `~/.config/omarchy/plugins/stompgate.widget/` | Bar widget |
| `~/.config/omarchy/extensions/omarchy-menu.jsonc` | A **marked block** of menu entries (backed up first; the rest isn't touched) |
| `~/.config/stompgate/config` | Display mode, if you set one |

**Downloads:**
- **GE-Proton** from GitHub, checked against a pinned SHA-512.
- **The Cortex Control installer** from `downloads.neuraldsp.com`, only if it
  isn't already in `~/Downloads`. It's checked against a pinned SHA-256.
- **umu's Steam runtime**, on first use.

**Network use while running:** each launch, the launcher checks once whether
`cloud.neuraldsp.com` is reachable, for the online indicator. Nothing else
contacts the network. Nothing is collected or sent anywhere by this project.

**Undo it all:** see [Uninstall](#uninstall). Everything above is removed or
restored, with backups of the config files it edited. The one exception is
umu's Steam runtime, which other umu apps (such as Omarchy's Battle.net) may
share. Delete `~/.local/share/umu/` yourself if nothing else uses it.

## Daily use

Start **Cortex Control** from the app launcher (Super + Space), or press
**Super + Shift + Q**. Omarchy's on-screen display shows "Starting
editor…" until the window appears, which takes several seconds. When the QC
is plugged in and on, the editor connects within a few seconds more.

**Quitting:** use **Quit** in the bar widget, **Trigger › Stompgate › Quit
Cortex Control** in the Omarchy menu, or `stompgate --quit`. They work even
while the editor is hidden, and ask it to close just as its close button
would. In gamescope mode, Super + W closes gamescope instead, which stops the
editor without asking it. If the editor is stuck and won't close,
`stompgate --quit --force` ends its Wine session.

### Keyboard shortcuts

| Keys | Action |
|---|---|
| **Super + Shift + Q** | Show or hide Cortex Control (starts it if closed) |
| **Super + Alt + Q** | Tuner on/off |
| **Super + Alt + N / P** | Next / previous scene |
| **Super + Alt + M** | Next mode: Preset → Scene → Stomp |
| **Super + Alt + B** | Tap tempo |
| **Super + Ctrl + Alt + 1–8** | Press footswitch 1–8 (on a QC mini: A–D on page I, then page II) |

**Seeing the current keys:**
- **Super + K** (Omarchy's keybindings menu), then search "Stompgate".
- The **Keys** link in the bar widget.
- **Learn › Stompgate** in the Omarchy menu.
- `stompgate --keys` in a terminal.

**Changing them:** edit `~/.config/hypr/stompgate.lua`. Hyprland reloads
when you save, and every list above follows your changes. Keep the
"Stompgate:" descriptions so those lists can find your bindings. Re-running setup keeps your edited file and writes any newer default
beside it as `stompgate.lua.new`.

### Tiling and window size

Cortex Control locks its window to about **1.4:1** and scales its whole UI to
that shape. A normal tile of any other shape, like half of a 16:9 screen,
would cut the UI off. There are two display modes:

| Mode | How it looks | Tiles cut off the UI? |
|---|---|---|
| **`gamescope`** (default when installed) | The app runs inside [gamescope](https://github.com/ValveSoftware/gamescope), which scales it to fit the tile with black bars at the edges. | **Never**, at any size or screen. Small tiles just make the text smaller. |
| **`window`** | A normal window, **pseudotiled**: it joins the tiling layout but keeps its 1.4:1 shape, centered in the tile, and shrinks evenly when the tile is smaller. | Only below about **800 px** wide, the app's own minimum size (for example, half of a 1366×768 laptop screen). |

In gamescope mode the app renders at about 80% of your monitor's height, so
gamescope mostly shrinks the picture and text stays sharp. Switch modes with
`stompgate-setup --display gamescope|window`, or for one launch with
`STOMPGATE_DISPLAY=window stompgate`. For a floating window instead,
use the alternative line in `~/.config/hypr/stompgate.lua` with `window`
mode.

### The bar widget

A sine-wave icon appears in the bar while Cortex Control is
open. It's dim when the QC isn't connected. Left-click opens the popup:

- **Header:** the device and its status, plus a **Hide / Show** button and,
  while the editor runs, **Quit**. Hidden, the editor keeps running and stays
  connected to the QC.
- **Mode & scenes:** Preset · Scene · Stomp, and scenes in two rows (I and II
  on the mini).
- **Footswitches:** presses the QC's switches. What a press does follows the
  current mode.
- **Tuner** and **Tap tempo**.
- **Audio:** the **Pro Audio** switch, plus output and input volume sliders.
  Right-click a slider to mute.
- **Footer:** setup status (click for the full doctor report), **Keys**, and
  the firmware reminder.

**Other ways to use it:**
- **Middle-click** the icon to show or hide the editor; **right-click** to
  refresh.
- **In the popup:** `1`–`8` for scenes, `m` for mode, `t` for the tuner, `k`
  for keys, `d` for the doctor, `q` to quit the editor, Enter to show or hide.

**Settings** (in the widget's settings):
- **Show icon:** `running` (default), `connected` (also while the QC is on), or
  `always`.
- **Status check interval.**

### From a terminal

```sh
stompgate [--show | --hide | --toggle | --quit [--force] | --keys]
stompgate-qc scene A-H | next | prev
stompgate-qc tuner open | close | toggle
stompgate-qc mode preset | scene | stomp | next | prev
stompgate-qc footswitch 1-8
stompgate-qc preset 38C [setlist]     # bank 38, slot C; setlist 1 = My Presets
stompgate-qc tap | gig-view open|close
stompgate-qc pro-audio on|off | volume output|input 0-150 | mute output|input
stompgate-doctor [--json | --status]
```

### How modes, scenes and footswitches behave

These use the incoming MIDI messages in Neural DSP's
[Quad Cortex mini manual (4.1.1)](https://neuraldsp.com/manual/quad-cortex-mini):

| Message | What it does |
|---|---|
| CC#43 | Scenes |
| CC#45 | Tuner |
| CC#46 | Gig View |
| CC#44 | Tap tempo |
| CC#47 | Mode slots |
| CC#35–42 | Footswitches |
| CC#0, CC#32 and Program Change | Presets |

- **MIDI only goes one way.** The QC never reports its scene, mode or tuner
  state. The highlights in the widget and the next/previous keys follow the
  **last command sent from this computer**. If you change something on the QC
  itself, they're out of step until your next press.
- **Mode slots, not mode names.** CC#47 picks mode *slots* 1–3, which are Preset,
  Scene and Stomp unless you reordered modes on the QC.
- **Footswitches act like stepping on the switch.** In Stomp mode they toggle
  effects, in Scene mode they recall scenes, and in Preset mode they load a
  preset from the current bank. **Loading a different preset may discard
  unsaved edits**, so save first.
- **There's no next/previous preset.** MIDI has no message for it. Load a
  specific preset with `stompgate-qc preset 38C`.

### Using the Quad Cortex as an audio interface

You don't need Cortex Control for audio. The QC is a standard USB audio device,
and PipeWire picks it up by itself.

- **For a DAW**, turn on **Pro Audio**, from the widget or with
  `stompgate-qc pro-audio on`. The channels then appear as plain `AUX0–7`
  instead of a 7.1 surround layout.
- **REAPER** runs natively on Linux. Install it (for example
  `omarchy pkg aur add reaper`) along with `pipewire-jack`. Then choose
  **Preferences → Audio → Device → JACK**.

## Troubleshooting

Start with:

```sh
stompgate-doctor
```

It checks the packages, XWayland, Vulkan, the pinned Proton, the prefix and app
hash, QC access and whether anything else has the QC open. It also checks MIDI,
audio, the shortcuts, the bar widget and the menu entries. It never starts Wine
or talks to the QC.

| Symptom | What to do |
|---|---|
| The Cortex Control UI is cut off in a tile | Install `gamescope` and run `stompgate-setup --display gamescope`. See [Tiling and window size](#tiling-and-window-size). |
| In gamescope mode the window never appears, or the launcher says it's opening a normal window instead | gamescope 3.16.31 and later wait for a configure that Hyprland 0.56.2 never sends after an unmap ([hyprwm/Hyprland#16444](https://github.com/hyprwm/Hyprland/pull/16444), fixed upstream but not released). Downgrade to gamescope 3.16.28 (`sudo pacman -U /var/cache/pacman/pkg/gamescope-3.16.28-1-x86_64.pkg.tar.zst` if it's still cached, otherwise from the [Arch Linux Archive](https://archive.archlinux.org/packages/g/gamescope/)) and add `IgnorePkg = gamescope` to `/etc/pacman.conf` until Hyprland updates. The doctor reports this. |
| The QC doesn't connect | Use a data cable and the logged-in desktop session. Run the doctor. Its "Quad Cortex … accessible" line must be OK. |
| Repeated `hidraw_device_set_output_report … Broken pipe` in the Wine log | Known and harmless: the QC rejects one optional message, and everything else works. |
| Scene, tuner or mode buttons do nothing | Turn on MIDI OVER USB on the QC and check its MIDI channel (1 or OMNI). `~/.local/state/stompgate/qc.log` shows what was sent. |
| The bar widget didn't change after an update | Run `omarchy restart shell`. The shell keeps the old widget code until it restarts. |
| You want a keybinding to open the widget's popup | Not possible: Omarchy lets only its own widgets register IPC. Use the shortcuts above, the menu or `stompgate-qc`. |
| The app says it's offline | The launcher checks `cloud.neuraldsp.com` and passes the result to a PowerShell shim. Check the doctor's "Neural DSP cloud" line. |
| Something else | See the launcher log at `~/.local/state/stompgate/last-run.log`. For a verbose log, run `WINEDEBUG=err+all stompgate` from a terminal. |

**Don't switch Wine to its Wayland driver.** The launcher keeps Cortex Control
on XWayland, because the Wayland driver gives it a Windows-style frame and
breaks resizing.

## Uninstall

```sh
stompgate-uninstall            # prefix, Proton, window rule, keys, widget, menu entries
stompgate-uninstall --keep-prefix   # integration only; keep the app and settings
sudo pacman -R stompgate
```

The uninstaller backs up `stompgate.lua` and the menu file before
changing them. Presets live on the Quad Cortex, not in the prefix.

## What's tested

Tested by hand in October 2026 on:

| | |
|---|---|
| Device | **Quad Cortex mini** (`152a:892f`) |
| Software | Cortex Control 4.1.0, umu-launcher 1.4.4, GE-Proton11-9 with DXVK 3.1.1 |
| System | Omarchy, Hyprland 0.56.2, kernel 7.2.5 |
| Graphics | NVIDIA RTX 3060 Ti, driver 610.57 |

**Works:**
- **App:** the editor draws; it connects over USB and shows the live preset
  grid, CPU load and the account linked on the device; it fetches from Cortex
  Cloud.
- **Install:** a full uninstall followed by a reinstall from the package
  completes.
- **Window and shortcuts:** show and hide; keyboard shortcuts with OSD
  feedback.
- **Tiling:** gamescope mode letterboxes the full UI into tiles from full size
  down to 601 px wide. In window mode, pseudotiling keeps the full UI down to
  801 px.
- **MIDI:** scene, tuner, mode and footswitch control.

**Not tested yet.** Reports are welcome; see [COMPATIBILITY.md](COMPATIBILITY.md):
- **Devices:** the **full-size Quad Cortex**. It's included in the udev rule
  and the controls, and Mordeton's project confirms it works under Proton.
- **Graphics:** AMD and Intel.
- **Install:** the setup **wizard** path. Testing used the silent install.
- **MIDI:** loading presets over MIDI, and Gig View.
- **Audio:** REAPER through JACK.
- **Cloud:** signing in to a Neural DSP account from the editor itself. Here the
  account was linked on the device.

**What we found along the way:**
- **0xteo's cfgmgr32 shim isn't needed.** Proton 11 finds the QC without it.
- **The PowerShell connectivity shim is kept but unused here.** The app never
  called PowerShell on this setup, and the shim is a fallback.

## How it works

- **Runtime:** [umu-launcher](https://github.com/Open-Wine-Components/umu-launcher)
  runs Cortex Control with a pinned
  [GE-Proton](https://github.com/GloriousEggroll/proton-ge-custom) in its own
  prefix. This is the same approach Omarchy uses for Battle.net. Pinning means
  Proton updates elsewhere can't change this setup.
- **QC connection:** `PROTON_ENABLE_HIDRAW=0x152A/0x880A,0x152A/0x892F` lets the
  app reach the QC's HID interface, which Proton otherwise hides. The udev rule
  gives your user access to that device node and nothing else.
- **Rendering:** DXVK (bundled with Proton) draws the JUCE/Direct2D UI. Without
  it the window is black.
- **Window:** in gamescope mode the launcher starts the app inside
  `gamescope -S fit`, a nested compositor that keeps the app at a fixed size and
  scales the picture to the tile. The launcher, widget and doctor find the
  window whether it's the app's own or gamescope's.
- **MIDI and audio:** `stompgate-qc` talks to the QC directly with `amidi`
  and `pactl`, separately from Cortex Control. That's why the controls also
  work while the editor is hidden.

## Credits

This project combines and builds on three earlier projects. Thank you to their
authors:

- **[0xteo/cortex-control-linux](https://github.com/0xteo/cortex-control-linux):**
  - the original Wine + DXVK approach,
  - the research into why hidapi couldn't see the QC (the cfgmgr32 shim),
  - the firmware warning,
  - the advice to stay on XWayland,
  - the note that the QC's "Broken pipe" errors are harmless.
- **[taylortek91/cortex-control-wine](https://github.com/taylortek91/cortex-control-wine):**
  - the Arch packaging approach,
  - the udev rule matched to product IDs,
  - the `powershell.bat` connectivity shim,
  - the note that the QC's "Broken pipe" errors are harmless.
- **[Mordeton/cortex-control-linux](https://github.com/Mordeton/cortex-control-linux):**
  - the Proton-based approach and enabling hidraw for the QC,
  - full-size QC testing on NVIDIA,
  - the design of the `doctor` diagnostics.

Their MIT license notices, and what this project took from each, are in
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

Also: Neural DSP for Cortex Control and the published MIDI implementation;
Valve, GloriousEggroll and the Open Wine Components team for Proton, GE-Proton
and umu-launcher; the Wine and DXVK projects; and Omarchy for the shell,
widgets and menu this hooks into.

## Contributing

Bug reports, compatibility reports and fixes are welcome. See
[CONTRIBUTING.md](CONTRIBUTING.md), and [CHANGELOG.md](CHANGELOG.md) for what's
changed.

## License

The scripts, widget and configuration here are [MIT](LICENSE) licensed, and
they build on MIT-licensed work listed in
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md). Cortex Control, Quad Cortex
and Neural DSP are trademarks of Neural DSP Technologies Oy, which isn't
involved with this project. Omarchy is not involved with it either.
