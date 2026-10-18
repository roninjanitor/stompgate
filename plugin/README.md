# Quad Cortex widget for the Omarchy bar

An [Omarchy](https://omarchy.org) bar widget for people who run Neural DSP's
Cortex Control editor on Linux with
**[cortex-control-omarchy](https://github.com/OWNER/cortex-control-omarchy)**.
<!-- Replace OWNER with the GitHub account when publishing. -->

> [!IMPORTANT]
> **Unofficial.** Not affiliated with, endorsed by or supported by Neural DSP
> Technologies or Omarchy. Neural DSP, Quad Cortex and Cortex Control are
> trademarks of Neural DSP Technologies Oy, used here only to say what this
> works with. **Never update the Quad Cortex's firmware through Cortex Control
> on Linux. Use Wi‑Fi updates on the device.**

**This widget needs the cortex-control-omarchy package.** It calls that
package's `cortex-control`, `cortex-control-qc` and `cortex-control-doctor`
commands, and does nothing useful without them. Install the package first.
Its setup also installs this widget for you, so most people don't need this
repository.

## What it does

A sine-wave icon appears in the bar while Cortex Control is open. It's dim
when the Quad Cortex isn't connected. Click it for:

- **Show / Hide** the editor. Hidden, it keeps running and stays connected.
- **Mode:** Preset · Scene · Stomp.
- **Scenes** and **footswitches**, two rows of four on the QC mini.
- **Tuner** on/off and **Tap tempo**.
- **Audio:** Pro Audio on/off (plain AUX channels for DAWs), plus output and
  input volume.
- **Footer:** setup status, a **Keys** list of the current keyboard shortcuts,
  and a firmware reminder.

**Clicks:**
- **Middle-click** shows or hides the editor.
- **Right-click** refreshes.

**In the popup:**
- `1`–`8`: scenes
- `m`: mode
- `t`: tuner
- `k`: keys
- `d`: doctor
- Enter: show or hide

MIDI only goes one way, so the QC never reports its scene, mode or tuner. The
highlights follow the last command sent from your computer.

## Install on its own

```sh
omarchy plugin add https://github.com/OWNER/omarchy-quad-cortex --enable
```

## Settings

- **Show icon:**
  - `running`, the default: only while Cortex Control is open.
  - `connected`: also while the QC is on.
  - `always`.
- **Status check interval** in seconds.

## License

[MIT](LICENSE). This widget is published from the `plugin/` folder of
cortex-control-omarchy. Report issues there.
