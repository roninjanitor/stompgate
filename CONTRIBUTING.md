# Contributing

Thanks for helping. This project is unofficial (see the
[disclaimer](README.md#disclaimer)). Please don't ask Neural DSP or the Omarchy
maintainers for support with it.

## Reporting problems

1. Run `cortex-control-doctor` and include its output.
2. If Cortex Control itself misbehaves, also attach
   `~/.local/state/cortex-control-omarchy/last-run.log`. For more detail, run
   `WINEDEBUG=err+all cortex-control` from a terminal and attach that.
3. For MIDI problems, include `~/.local/state/cortex-control-omarchy/qc.log`.
4. **Remove anything personal** before posting: usernames in paths, account
   names, serial numbers.

Compatibility reports, including "it just works" ones, are just as useful. See
[COMPATIBILITY.md](COMPATIBILITY.md).

## Ground rules for changes

- **Never automate firmware updates or factory resets,** and never add
  anything that writes to the Quad Cortex's HID interface. That protocol is
  Cortex Control's. This project only uses Neural DSP's documented incoming
  MIDI messages.
- **Don't add Neural DSP software or artwork** to the repository, and don't use
  their logo or anything resembling it as this project's branding.
- **The udev rule must stay limited** to the Quad Cortex (`152a:880a`) and Quad
  Cortex mini (`152a:892f`).
- **Ask before sudo:** the package and its install hook are the only places
  that run as root. Per-user setup must work without sudo.
- **Respect the user's files:** back up before editing a config file, edit only
  inside our marked block or our own file, and keep user edits (see how setup
  handles `cortex-control.lua.new`).
- **Match Omarchy's conventions:** `o.bind` / `o.window` in Hyprland Lua,
  `omarchy-*` helpers, the shell's own UI components in the widget.

## Developing

Everything runs from a checkout. The commands find `lib/` and the widget
relative to the repo, so you can test without installing:

```sh
./bin/cortex-control-doctor
./bin/cortex-control-setup --silent
CORTEX_CONTROL_MIDI_DRY_RUN=1 ./bin/cortex-control-qc scene next   # prints MIDI, sends nothing
omarchy plugin validate plugin
bash -n bin/* lib/*.sh
```

After changing the widget, run setup to copy it into place, then
`omarchy restart shell`. The shell keeps the old widget code until it
restarts.

## Releasing

1. Update `pkgver` (and reset `pkgrel=1`) in `PKGBUILD`, the `version` in
   `plugin/manifest.json`, and `CHANGELOG.md`.
2. Build and test: `makepkg -fsi`, then run setup and the doctor.
3. Commit, then tag with `git tag -a vX.Y.Z -m "vX.Y.Z"`.

### Publishing the bar widget on its own

Omarchy's plugin directory and `omarchy plugin add` need a repository with
`manifest.json` at its root. The `plugin/` folder is set up for that, with its
own README and LICENSE. To publish it as a separate repository from this one:

```sh
git subtree split --prefix plugin -b widget-release
git push <widget-repo-url> widget-release:main
```

Run the same two commands after each release to update it. The widget needs
this project's package to be installed, and its README says so.
