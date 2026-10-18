# Start my keyboard layout on Windows with kanata. No admin needed.
#
#   From the release zip:  double-click start.bat
#   One line, no download:  irm https://raw.githubusercontent.com/H7ioo/keymap/main/windows/run.ps1 | iex
#   With an option:         & ([scriptblock]::Create((irm https://raw.githubusercontent.com/H7ioo/keymap/main/windows/run.ps1))) -Stop
#
# Options: -Stop (quit kanata), -Autostart (also start at login), -RemoveAutostart
param([switch]$Stop, [switch]$Autostart, [switch]$RemoveAutostart)
$ErrorActionPreference = 'Stop'

$KanataVersion = 'v1.12.0'
$KanataZipSha256 = '13947ed78cfa3284bfef854e3c542c74ab366236b72fd9f7e039f8638deead9d'
$KanataExeInZip = 'kanata_windows_gui_winIOv2_x64.exe'  # tray icon, no console window, no driver
$ConfigUrl = 'https://raw.githubusercontent.com/H7ioo/keymap/main/kanata.kbd'

$Dir = Join-Path $env:LOCALAPPDATA 'keymap'
$Exe = Join-Path $Dir 'kanata.exe'
$Cfg = Join-Path $Dir 'kanata.kbd'
$Shortcut = Join-Path ([Environment]::GetFolderPath('Startup')) 'keymap.lnk'

Get-Process kanata -ErrorAction SilentlyContinue | Stop-Process -Force
if ($Stop) { Write-Host 'keymap: stopped.'; return }
if ($RemoveAutostart) { Remove-Item $Shortcut -ErrorAction SilentlyContinue; Write-Host 'keymap: autostart removed.'; return }

New-Item -ItemType Directory -Force $Dir | Out-Null

# Prefer the files next to this script (release zip), otherwise download them.
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { $null }
if ($Here -and (Test-Path (Join-Path $Here 'kanata.exe'))) {
  Copy-Item (Join-Path $Here 'kanata.exe') $Exe -Force
} elseif (-not (Test-Path $Exe)) {
  $Zip = Join-Path $Dir 'kanata.zip'
  Write-Host "keymap: downloading kanata $KanataVersion..."
  Invoke-WebRequest -UseBasicParsing "https://github.com/jtroo/kanata/releases/download/$KanataVersion/windows-binaries-x64.zip" -OutFile $Zip
  if ((Get-FileHash $Zip -Algorithm SHA256).Hash -ne $KanataZipSha256) {
    Remove-Item $Zip
    throw 'keymap: kanata download does not match the expected checksum, not running it.'
  }
  $Unpacked = Join-Path $Dir 'kanata-zip'
  Expand-Archive $Zip -DestinationPath $Unpacked -Force
  Copy-Item (Join-Path $Unpacked $KanataExeInZip) $Exe -Force
  Remove-Item $Zip, $Unpacked -Recurse
}
if ($Here -and (Test-Path (Join-Path $Here 'kanata.kbd'))) {
  Copy-Item (Join-Path $Here 'kanata.kbd') $Cfg -Force
} else {
  Invoke-WebRequest -UseBasicParsing $ConfigUrl -OutFile $Cfg
}

Start-Process $Exe -ArgumentList '--cfg', "`"$Cfg`"" -WorkingDirectory $Dir

if ($Autostart) {
  $Link = (New-Object -ComObject WScript.Shell).CreateShortcut($Shortcut)
  $Link.TargetPath = $Exe
  $Link.Arguments = "--cfg `"$Cfg`""
  $Link.WorkingDirectory = $Dir
  $Link.Save()
  Write-Host 'keymap: will also start at login.'
}

Write-Host 'keymap: running (kanata icon in the tray).'
Write-Host '  Tap Caps = Esc | hold Caps = Ctrl | Caps+H = Backspace'
Write-Host '  Stop: right-click the tray icon, or press Left Ctrl + Space + Esc together.'
