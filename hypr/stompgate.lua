-- Neural DSP Cortex Control under Proton/XWayland (installed by stompgate-setup).
--
-- Change any key below to suit you, then save; Hyprland reloads by itself.
-- stompgate-setup keeps your edits: a newer default is written next to
-- this file as stompgate.lua.new instead. List the current keys with
-- Super + K (search "Stompgate") or: stompgate --keys
-- Keep the "Stompgate:" descriptions so the keys menu
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
o.bind("SUPER + SHIFT + Q", "Stompgate: show or hide Cortex Control", "stompgate --toggle")
o.bind("SUPER + ALT + Q", "Stompgate: tuner on/off", "stompgate-qc --osd tuner toggle")
o.bind("SUPER + ALT + N", "Stompgate: next scene", "stompgate-qc --osd scene next")
o.bind("SUPER + ALT + P", "Stompgate: previous scene", "stompgate-qc --osd scene prev")
o.bind("SUPER + ALT + B", "Stompgate: tap tempo", "stompgate-qc --osd tap")
o.bind("SUPER + ALT + M", "Stompgate: next mode (preset/scene/stomp)", "stompgate-qc --osd mode next")

-- Footswitch presses, 1-8 by keycode like Omarchy's workspace keys. What a press
-- does follows the QC's mode (stomp toggle, preset in bank, scene).
for n = 1, 8 do
  o.bind("SUPER + CTRL + ALT + code:" .. tostring(n + 9), "Stompgate: footswitch " .. n, "stompgate-qc --osd footswitch " .. n)
end
