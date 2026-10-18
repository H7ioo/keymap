# keymap

My Caps Lock layout, on any Windows or Linux PC, with one download.

| Press | Get |
|---|---|
| Tap Caps Lock | Esc |
| Hold Caps Lock + key | Ctrl + key |
| Caps Lock + H | Backspace (in every app) |
| Real Ctrl + H | Unchanged |

Uses [kanata](https://github.com/jtroo/kanata) (pinned to v1.12.0, checksum-verified on download).
My own Linux machines use keyd with the same behavior, set up from my dotfiles.

## Windows (no admin needed)

**Zip:** download `keymap-windows-x64.zip` from [Releases](../../releases/latest), unzip, double-click `start.bat`.
If SmartScreen warns, choose *More info → Run anyway*.

**Or one line in PowerShell:**
```powershell
irm https://raw.githubusercontent.com/H7ioo/keymap/main/windows/run.ps1 | iex
```

Stop: right-click the kanata tray icon, run `start.bat /stop`, or press Left Ctrl + Space + Esc.
On your own PC, start it at every login:
```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/H7ioo/keymap/main/windows/run.ps1))) -Autostart
```

## Linux (Pardus, Fedora, Ubuntu, ...)

```bash
curl -fsSL https://raw.githubusercontent.com/H7ioo/keymap/main/linux/run.sh | bash
```

- **With sudo:** runs kanata with the full layout above. Stop with Ctrl+C or Left Ctrl + Space + Esc.
- **Without sudo** (e.g. a uni PC): kanata can't run, so the script makes Caps Lock a plain Ctrl instead.
  Caps+H is Backspace in terminals and Neovim only, and Caps+[ is Esc. Undo with `... | bash -s -- --undo`.

## Tests

`tests/*.sim` are scripted key presses; `tests/*.expected` are the exact keys kanata must send.
CI runs them through kanata's simulator, and loads the config in the real Windows and Linux kanata.

```bash
SIM=/path/to/kanata_simulated_input tests/run.sh            # check
SIM=/path/to/kanata_simulated_input tests/run.sh --update   # after changing kanata.kbd on purpose
```

### Manual check on a real PC

Open Notepad (or a terminal) and try:

| Do | Expect |
|---|---|
| Type `abc`, then Caps + H | `ab` |
| Hold Caps + H | Keeps deleting |
| Caps + A | Selects all |
| Tap Caps in Neovim insert mode | Back to normal mode |
| Real Ctrl + H in a browser | History opens |
