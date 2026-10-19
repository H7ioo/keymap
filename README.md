# keymap

Turn Caps Lock into the most useful key on the keyboard: Esc, Ctrl and Backspace in one key.
It works on any Windows or Linux PC from one download, with no installer, and on Windows no admin.

## Keybindings

| You press | You get | Why |
|---|---|---|
| **Tap** Caps Lock | `Esc` | Leave insert mode in Neovim and close dialogs without reaching |
| **Hold** Caps Lock + any key | `Ctrl` + that key | Caps+C, Caps+V, Caps+W, … right on the home row |
| Caps Lock + `H` | `Backspace` | Delete without leaving the home row, in every app |
| Hold Caps Lock + `H` | Repeated `Backspace` | Works like holding Backspace |
| Real `Ctrl` + `H` | `Ctrl` + `H` (unchanged) | Browser history, find and replace, etc. still work |
| Left `Ctrl` + `Space` + `Esc` | Quit the layout | Emergency stop, keyboard back to normal |

A tap is a press shorter than 200 ms with no other key in between. Anything longer, or with
another key pressed while Caps is down, counts as a hold (so a fast Caps+H roll is still Backspace).

### Linux without sudo

Kanata needs root on Linux. Without it, the script falls back to a plain remap that any user can set:

| You press | You get |
|---|---|
| Caps Lock + any key | `Ctrl` + that key |
| Caps Lock + `H` | `Backspace` in terminals and Neovim only (it's Ctrl+H) |
| Caps Lock + `[` | `Esc` (Vim treats Ctrl+[ as Esc) |
| Tap Caps Lock | Nothing |

## Windows

No admin needed.

**Zip:** download `keymap-windows-x64.zip` from [Releases](../../releases/latest), unzip it,
and double-click `start.bat`. If SmartScreen warns, choose *More info → Run anyway*.

**Or paste one line into PowerShell:**
```powershell
irm https://raw.githubusercontent.com/H7ioo/keymap/main/windows/run.ps1 | iex
```

A kanata icon appears in the tray while it runs.

Without admin rights, Windows doesn't let kanata remap keys inside windows that run as admin
(Task Manager, UAC prompts, admin terminals). Caps Lock acts normally there.

| To | Do |
|---|---|
| Stop | Right-click the tray icon, run `start.bat /stop`, or press Left Ctrl + Space + Esc |
| Start at every login (your own PC) | `& ([scriptblock]::Create((irm https://raw.githubusercontent.com/H7ioo/keymap/main/windows/run.ps1))) -Autostart` |
| Remove autostart | Same command with `-RemoveAutostart` |

## Linux

Works on Pardus, Fedora, Ubuntu and other x86-64 distros:

```bash
curl -fsSL https://raw.githubusercontent.com/H7ioo/keymap/main/linux/run.sh | bash
```

- **With sudo:** runs kanata with the full layout. Stop it with Ctrl+C or Left Ctrl + Space + Esc.
- **Without sudo:** applies the fallback above. It only asks for a password if your account is an admin.
- **Undo:** `curl -fsSL https://raw.githubusercontent.com/H7ioo/keymap/main/linux/run.sh | bash -s -- --undo`

For my own Linux machines I use keyd with the same behavior, set up from my dotfiles.

## How it works

[kanata](https://github.com/jtroo/kanata) remaps keys below the apps, so the layout works everywhere.
The whole layout is the [`kanata.kbd`](kanata.kbd) file. The scripts download kanata v1.12.0 from its
official releases and refuse to run it unless its checksum matches.

## Tests

Every push is tested in CI:

- **Key tests:** `tests/*.sim` are scripted key presses, and `tests/*.expected` are the exact keys kanata
  must send back. They run through kanata's own simulator, the same engine as on Windows and Linux.
- **Real binaries:** the config is loaded by the real Windows and Linux kanata.
- **Scripts:** shellcheck, PowerShell parsing, and a check that the pinned checksums match kanata's release.

Run the key tests locally:
```bash
SIM=/path/to/kanata_simulated_input tests/run.sh            # check
SIM=/path/to/kanata_simulated_input tests/run.sh --update   # after changing kanata.kbd on purpose
```

### Quick check on a new PC

Open Notepad or a terminal and try:

| Do | Expect |
|---|---|
| Type `abc`, then Caps + H | `ab` |
| Hold Caps + H | Keeps deleting |
| Caps + A | Selects all |
| Tap Caps in Neovim insert mode | Normal mode |
| Real Ctrl + H in a browser | History opens |

## Releases

Push a tag like `v2` and CI builds `keymap-windows-x64.zip` (kanata, the config, the scripts and kanata's
license) and attaches it to a GitHub release.
