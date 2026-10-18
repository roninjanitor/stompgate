# Third-party notices

stompgate is MIT licensed (see [LICENSE](LICENSE)). It builds on
three earlier MIT-licensed projects. Their notices are reproduced below, along
with what this project took from each.

This repository contains **no Neural DSP software**. Cortex Control is
installed from the user's own copy of Neural DSP's official installer and is
covered by Neural DSP's license, which the user accepts during setup. GE-Proton,
umu-launcher, DXVK, gamescope and the Nerd Font glyphs referenced by the
widget are not bundled either. They are downloaded or installed separately
under their own licenses.

## taylortek91/cortex-control-wine

<https://github.com/taylortek91/cortex-control-wine>

**Adapted here:**
- the udev rule matched to the Quad Cortex's product IDs (`udev/`),
- the `powershell.bat` connectivity shim and the launcher logic that feeds it
  (`shims/powershell.bat`, `bin/stompgate`),
- the Arch packaging layout and the per-user setup and uninstall split.

```
MIT License

Copyright (c) 2026 Cortex Control Wine contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 0xteo/cortex-control-linux

<https://github.com/0xteo/cortex-control-linux>

**Built on, with no code copied:**
- the Wine + DXVK approach,
- the hidapi/cfgmgr32 research,
- the firmware warning and the advice to stay on XWayland,
- the note that the QC's "Broken pipe" output-report errors are harmless.

```
MIT License

Copyright (c) 2026 0xteo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Mordeton/cortex-control-linux

<https://github.com/Mordeton/cortex-control-linux>

**Built on, with no code copied:**
- the Proton-based approach and enabling hidraw for the QC,
- full-size Quad Cortex testing on NVIDIA,
- the read-only `doctor` diagnostics design, reimplemented here as
  `stompgate-doctor`.

```
MIT License

Copyright (c) 2026 Cortex Control Linux contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
