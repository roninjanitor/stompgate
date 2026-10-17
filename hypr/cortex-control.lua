-- Neural DSP Cortex Control under Proton/XWayland (installed by cortex-control-setup).
-- The app locks its window to about 1.4:1 and scales its UI to fit, so a tile of
-- any other shape crops it. Float it instead, and keep that ratio when resizing.
o.window({ class = "^steam_app_cortexcontrol$" }, { float = true, center = true, size = { 1600, 1140 }, keep_aspect_ratio = true })
