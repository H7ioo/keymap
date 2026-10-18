@echo off
rem Double-click to start the keyboard layout. Pass /stop to quit it.
if /i "%~1"=="/stop" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run.ps1" -Stop
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run.ps1"
)
pause
