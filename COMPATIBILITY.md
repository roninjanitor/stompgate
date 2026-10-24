# Compatibility

What has been tested, and how to report your own setup. This project is
unofficial and not supported by Neural DSP; see the
[disclaimer](README.md#disclaimer).

## Tested setups

| Date | Device | CorOS | Cortex Control | GPU and driver | Screen | Omarchy / Hyprland | Display mode | Result |
|---|---|---|---|---|---|---|---|---|
| 2026-10 | Quad Cortex mini | not recorded | 4.1.0 | NVIDIA RTX 3060 Ti, 610.57 | 3440×1440 | Hyprland 0.56.2 | gamescope and window | ✅ Works: editing, scenes, tuner, modes, footswitches, tiling |
| 2026-10-24 | Quad Cortex mini | not recorded | 4.1.0 | NVIDIA RTX 3060 Ti, 615.78 | 3440×1440 | Hyprland 0.56.2-4, gamescope 3.16.28 | gamescope | ✅ Works. gamescope 3.16.31 and 3.17.0 on this Hyprland never show the window; see the README's troubleshooting table |

Everything else is untested so far:
- the full-size Quad Cortex,
- AMD and Intel GPUs,
- 1080p and laptop screens,
- the setup wizard install path,
- loading presets and Gig View over MIDI,
- REAPER through JACK,
- signing in from inside the editor.

The full-size Quad Cortex is handled by the udev rule and the controls, and
[Mordeton's project](https://github.com/Mordeton/cortex-control-linux) has run
it under Proton.

## Report your setup

Open an issue using the **Compatibility report** template, or copy this:

```
Device:            Quad Cortex / Quad Cortex mini
CorOS version:     (Cortex Control: Device Settings > Device Information)
Cortex Control:    4.1.0
GPU and driver:    (e.g. AMD RX 7800 XT, mesa 25.x)
Screen:            (resolution, and laptop or external)
Omarchy version:   (omarchy version)
Display mode:      gamescope / window
Package version:   (pacman -Q stompgate)

What works:        (editor draws / QC connects / editing / scenes / tuner /
                    modes / footswitches / tiling / audio in a DAW / ...)
What doesn't:

stompgate-doctor output:
(paste here)
```

**Check what you paste.** The doctor's output contains file paths with your
username, and `last-run.log` can contain more. Remove anything you'd rather
not share.
