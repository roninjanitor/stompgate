-- Neural DSP Cortex Control under Proton/XWayland (installed by cortex-control-setup).
--
-- Change any key below to suit you, then save; Hyprland reloads by itself.
-- cortex-control-setup keeps your edits: a newer default is written next to
-- this file as cortex-control.lua.new instead. List the current keys with
-- Super + K (search "Quad") or: cortex-control --keys
-- Keep the "Quad Cortex:" / "Cortex Control:" descriptions so the keys menu
-- and the bar widget can find your bindings.
-- The app locks its window to about 1.4:1 and scales its UI to fit, so a plain
-- tile of another shape crops it. Pseudotile it instead: it joins the tiling
-- layout but keeps its 1.4:1 shape, centered in its tile, and Hyprland scales it
-- down evenly when the tile is smaller. Below about 800 px wide the app reaches
-- its minimum size and gets cropped slightly.
o.window({ class = "^steam_app_cortexcontrol$" }, { tile = true, pseudo = true, size = { 1600, 1140 } })
-- With display=gamescope (the default when gamescope is installed) the app runs
-- inside a gamescope window that tiles normally and letterboxes the app into any
-- tile size; the rule above then applies only in display=window mode.
-- Prefer a floating window? Use this line instead of the pseudotile one:
-- o.window({ class = "^steam_app_cortexcontrol$" }, { float = true, center = true, size = { 1600, 1140 }, keep_aspect_ratio = true })

-- Keyboard control. Q for Quad Cortex. Scenes and the tuner go over MIDI, so the
-- QC needs MIDI OVER USB on (Settings > Device > MIDI); each press shows the OSD.
o.bind("SUPER + SHIFT + Q", "Cortex Control: show or hide", "cortex-control --toggle")
o.bind("SUPER + ALT + Q", "Quad Cortex: tuner on/off", "cortex-control-qc --osd tuner toggle")
o.bind("SUPER + ALT + N", "Quad Cortex: next scene", "cortex-control-qc --osd scene next")
o.bind("SUPER + ALT + P", "Quad Cortex: previous scene", "cortex-control-qc --osd scene prev")
o.bind("SUPER + ALT + B", "Quad Cortex: tap tempo", "cortex-control-qc --osd tap")
o.bind("SUPER + ALT + M", "Quad Cortex: next mode (preset/scene/stomp)", "cortex-control-qc --osd mode next")

-- Footswitch presses, 1-8 by keycode like Omarchy's workspace keys. What a press
-- does follows the QC's mode (stomp toggle, preset in bank, scene).
for n = 1, 8 do
  o.bind("SUPER + CTRL + ALT + code:" .. tostring(n + 9), "Quad Cortex: footswitch " .. n, "cortex-control-qc --osd footswitch " .. n)
end
