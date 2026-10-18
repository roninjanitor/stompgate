-- Neural DSP Cortex Control under Proton/XWayland (installed by cortex-control-setup).
-- The app locks its window to about 1.4:1 and scales its UI to fit, so a tile of
-- any other shape crops it. Float it instead, and keep that ratio when resizing.
o.window({ class = "^steam_app_cortexcontrol$" }, { float = true, center = true, size = { 1600, 1140 }, keep_aspect_ratio = true })

-- Keyboard control. Q for Quad Cortex. Scenes and the tuner go over MIDI, so the
-- QC needs MIDI OVER USB on (Settings > Device > MIDI); each press shows the OSD.
o.bind("SUPER + SHIFT + Q", "Cortex Control: show or hide", "cortex-control --toggle")
o.bind("SUPER + ALT + Q", "Quad Cortex: tuner on/off", "cortex-control-qc --osd tuner toggle")
o.bind("SUPER + ALT + N", "Quad Cortex: next scene", "cortex-control-qc --osd scene next")
o.bind("SUPER + ALT + P", "Quad Cortex: previous scene", "cortex-control-qc --osd scene prev")
o.bind("SUPER + ALT + B", "Quad Cortex: tap tempo", "cortex-control-qc --osd tap")
