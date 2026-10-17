@echo off
rem Cortex Control checks connectivity with "powershell Get-NetAdapter", which
rem Wine's PowerShell stub can't answer. The launcher checks the network on the
rem Linux side and passes the result in CORTEX_CONTROL_HOST_ONLINE.
rem From taylortek91/cortex-control-wine.
if "%CORTEX_CONTROL_HOST_ONLINE%"=="1" (
  echo 1
) else (
  echo 0
)
exit /b 0
