# AGENTS.md — Arch + Hyprland system guide

A guide for AI agents (and humans) working on this machine. Read it before you
install software, edit dotfiles, or restart parts of the desktop. Everything
here describes this specific system; it is not generic Arch advice.

Last surveyed: 2026-11-03.

---

## 1. Ground rules

- **Never commit; only stage.** The owner reviews and commits by hand. You may
  `git add` the files you changed in `~/.config`.
- **Never lose local changes.** Don't use `git reset --hard`, `git checkout -- <file>`,
  `git clean`, or `git stash` unless asked. Many files in `~/.config` are not
  tracked, so git can't bring them back.
- **sudo needs a password.** You can't run `sudo` without the owner. Ask
  them to run privileged commands with the `!` prefix, or give them the exact
  command to run.
- **Don't edit generated files.** These are written by tools:
  `~/.config/hypr/colors/current-theme/*` and the symlinks that point to it,
  `~/.config/hypr/monitors.lua` (nwg-displays), and `~/.cache/wal/*` (pywal).
  Change the source instead (see section 6).
- **Back up before a big edit.** Copy the file to a scratch folder first,
  so you can restore it if a test goes wrong.
- **Don't change boot, disk, or kernel settings** (GRUB, mkinitcpio, fstab,
  swap) without explicit approval.

---

## 2. Hardware and OS

| Item | Value |
|---|---|
| Machine | HP EliteBook 850 G8 laptop |
| CPU / GPU | Intel Core i7-1165G7 (Tiger Lake), Intel Iris Xe graphics (`intel-media-driver`, `vulkan-intel`) |
| RAM | 16 GB |
| Wi-Fi / audio | Intel AX201 Wi-Fi 6; Intel HDA audio with `sof-firmware` |
| Fingerprint reader | `fprintd` installed |
| OS | Arch Linux, rolling, `linux` kernel (7.2.x) |
| Boot | UEFI + GRUB (`/boot` is the 1 GB vfat ESP). Secure Boot off. Kernel cmdline: `loglevel=3 quiet` |
| initramfs | mkinitcpio with systemd hooks: `base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems fsck` |
| Disk | `nvme0n1`: p1 ESP `/boot`, p2 20 GB swap, p3 ext4 `/` (about 456 GB) |
| Hibernate | **Not set up**: no `resume=` on the cmdline. Suspend works. |
| Snapshots | Timeshift (rsync mode, ext4) with `timeshift-boot.timer` and `timeshift-hourly.timer` |
| Locale / keyboard | Belgian AZERTY (`kb_layout = "be"`); the system language is Dutch, so some tool output is in Dutch |

---

## 3. Packages

- **Package managers:** `pacman` and the AUR helper **`yay`** (paru is not installed).
  Install with `yay -S <pkg>` or `sudo pacman -S <pkg>`. About 1,800 packages
  are installed.
- **Before installing:** check whether the package already exists
  (`pacman -Q <pkg>`, `pacman -Qs <term>`). Prefer the official repos over the
  AUR, and `-bin` AUR packages over packages that build from source.
- **Don't run a partial upgrade** (`pacman -Sy <pkg>`). Use `-S` or a full
  `-Syu`.
- **Notable AUR or `-git` packages:** `aylurs-gtk-shell-git` (AGS v3) with
  the `libastal-*-git` libraries, `swww-git`, `zen-browser-bin`,
  `librewolf-bin`, `visual-studio-code-bin`, `intellij-idea-ultimate-edition`,
  `spotify`, `hyprshade`, `icaclient` (Citrix), `packettracer`, `sdrpp-git`,
  `satdump`, `onedrive-abraunegg`, `postman-bin`, `slack-desktop`.
  Rebuilding `-git` packages can break AGS. After updating the astal
  libraries, test the AGS widgets.
- **Python:** `pywal` (`wal`) lives in `~/.local/bin` (installed with pip or pipx),
  not pacman. Use `pipx` for Python CLI tools; never `sudo pip`.
- **Helper scripts:** `~/.config/hypr/scripts/fzf-pacman.sh` and
  `fzf-pacman-installed.sh` are fzf pickers for packages.

### Main software by role

| Role | Program |
|---|---|
| Compositor | **Hyprland 0.56** (configured in **Lua**, see section 5) |
| Session start | `ly` display manager → `hyprland-uwsm.desktop` (uwsm, so Hyprland runs as the systemd user unit `wayland-wm@hyprland.desktop.service`) |
| Bar | Waybar |
| Launcher | Wofi (replaced Rofi) |
| Notifications | **SwayNC** (replaced Mako, which is **uninstalled**) |
| OSD and audio panel | **AGS v3** (GTK4, TypeScript/JSX), instance name `osd` |
| Wallpaper | `swww` (swww-daemon) |
| Lock / idle | `hyprlock`, `hypridle` |
| Polkit agent | `hyprpolkitagent` (user service) |
| Screen filters | `hyprshade` (GLSL shaders in `hypr/shaders/`), `hyprsunset` (night mode) |
| Terminal | `kitty` (also `alacritty`) |
| Shell | `zsh` + oh-my-zsh (theme `robbyrussell`; plugins `git`, `zsh-vi-mode`, `colored-man-pages`), zsh-syntax-highlighting, fzf |
| Editor | Neovim (`EDITOR=nvim`), config in the git submodule `~/.config/nvim` |
| Browser | Zen Browser (default `$browser`); also Firefox, LibreWolf, Chromium |
| File manager | Dolphin |
| Audio | PipeWire + WirePlumber + pipewire-pulse; `pavucontrol` |
| Network | NetworkManager (`nm-applet`), `iwd` installed, systemd-resolved, Tailscale, WireGuard, OpenVPN |
| Bluetooth | bluez + `blueman-applet` |
| Power | TLP (governor: performance on AC, ondemand on battery), `batsignal` battery alerts, upower, powertop |
| Firewall | `ufw` (enabled) |
| Screenshots | `grim` + `slurp` (+ `wl-clipboard`) |
| Theming | GTK theme Adwaita (prefer-dark), icons `WhiteSur-dark` (also `papirus`), cursor size 16, `QT_QPA_PLATFORMTHEME=gtk3`; set with `nwg-look` |
| Monitors | `nwg-displays` (writes `hypr/monitors.lua`) |
| Other | KDE Connect, Nextcloud client, OneDrive, Docker, QEMU/virt-manager, Waydroid, Steam |

---

## 4. Services

**System units (enabled):** NetworkManager (+ dispatcher, wait-online),
systemd-resolved, systemd-timesyncd, ntpd, bluetooth, docker, tailscaled,
tlp, ufw, upower, avahi-daemon, prometheus-node-exporter, reflector (timer),
timeshift timers.

**User units (enabled):**

| Unit | Purpose |
|---|---|
| `batsignal.service` | Battery alerts; config in `~/.config/batsignal` (see section 9) |
| `monitor-hook.service` | `~/.config/systemd/user/monitor-hook.service` runs `hypr/scripts/hyprland-monitor-hook.sh`, which listens on the Hyprland socket and restores the wallpaper when a monitor is plugged in |
| `hyprpolkitagent.service` | Polkit prompts |
| `gnome-keyring-daemon` | Secrets |
| `pipewire`, `pipewire-pulse`, `wireplumber` | Audio |

`swaync.service` is D-Bus activated and also launched from autostart.

**User units started by udev (disabled on purpose):**
`app-dev.lizardbyte.app.Sunshine.service` and `ivm-watch.service` run only
while the iPad is plugged in (see section 10). Don't `enable` them.

Restart a user service with `systemctl --user restart <unit>`, and read its
log with `journalctl --user -u <unit>`.

---

## 5. Hyprland (Lua config)

Hyprland is configured in **Lua**, not hyprlang. The entry point is
`~/.config/hypr/hyprland.lua`. `hyprland.conf` and the `conf/*.conf` files are
**old hyprlang leftovers kept for reference; they are not loaded.** Edit the
`.lua` files.

### Layout

```
~/.config/hypr/
├── hyprland.lua            # requires conf.* in order
├── monitors.lua            # GENERATED by nwg-displays — don't hand-edit
├── colors.lua → colors/current-theme/hypr.lua   # theme colours (generated)
├── colors.conf → colors/current-theme/hypr.conf # same, hyprlang (used by hyprlock)
├── hypridle.conf, hyprlock.conf, hyprpaper.conf  # still hyprlang (separate tools)
├── conf/
│   ├── variables.lua       # term=kitty, filemanager=dolphin, menu=wofi, browser=zen-browser
│   ├── autostart.lua       # hl.on("hyprland.start", ...) exec list
│   ├── windowrules.lua     # hl.window_rule / hl.layer_rule
│   ├── keybindings.lua     # hl.bind
│   ├── monitors.lua        # require("monitors")
│   ├── environment.lua     # hl.env(...)
│   ├── input.lua           # be layout, natural scroll
│   ├── animations.lua      # → animations/animations-fast.lua (active preset)
│   ├── windows.lua         # → windows/default.lua (gaps 4/6, border 1, accent border colour)
│   ├── decorations.lua     # → decorations/rounding-classic.lua (rounding 10, blur, shadow)
│   ├── layout.lua, misc.lua, permissions.lua, custom.lua
├── colors/                 # theme framework (section 6)
├── scripts/                # helper scripts (section 8)
└── shaders/                # hyprshade GLSL shaders
```

Monitors: `eDP-1` 1920x1080 at 0x0, `HDMI-A-1` 1920x1080 at 1920x0,
`DP-2` 1600x900 at 3840x0, all at scale 1. While the iPad streams, there is
also a virtual output `MOONLIGHT` (2360x1640, scale 1.67, see section 10).

### Lua API cheat sheet (as used in this config)

```lua
hl.config({ general = { gaps_in = 4 } })
hl.env("EDITOR", "nvim")
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("..."), { repeating = true })
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.window_rule({ match = { class = "..." }, float = true })
hl.layer_rule({ match = { namespace = "ags-osd" }, animation = "slide bottom" })
hl.animation({ leaf = "layersIn", ... })
hl.on("hyprland.start", function() hl.exec_cmd("...") end)
hl.get_active_window(), hl.get_active_monitor(), hl.get_config("cursor.zoom_factor")
```

### hyprctl with a Lua config

- `hyprctl keyword ...` **no longer works**. To change a setting at runtime, use a
  Lua bind or function that calls `hl.config`.
- Dispatch takes Lua expressions:
  `hyprctl dispatch 'hl.dsp.exec_cmd("cmd")'`,
  `hyprctl dispatch 'hl.dsp.dpms({ action = "off" })'`,
  `hyprctl dispatch 'hl.dsp.cursor.move({ x = 100, y = 100 })'`.
- `hyprctl reload` reloads the config. `hyprctl monitors -j`, `clients -j`
  and `layers -j` work as usual.
- To start a GUI program detached from your shell, use
  `hyprctl dispatch 'hl.dsp.exec_cmd("...")'`.

### Key bindings (SUPER = main modifier)

| Keys | Action |
|---|---|
| SUPER+Return / B / E | kitty / zen-browser / dolphin |
| SUPER+Space | wofi drun |
| SUPER+Q | close window |
| SUPER+F, SUPER+SHIFT+F, SUPER+M | fullscreen, fake fullscreen, maximize |
| SUPER+T | toggle floating (resizes to 65%x70% of the monitor and centres) |
| SUPER+H/J/K/L | move focus |
| SUPER+SHIFT+H/L | previous/next workspace |
| SUPER+CTRL+H/L | move window to previous/next workspace |
| SUPER+1…0 / SUPER+SHIFT+1…0 | go to / move window to workspace (number-row keycodes `code:10..19`, because of AZERTY) |
| SUPER+CTRL+SHIFT+H/J/K/L | move workspace to another monitor |
| SUPER+SHIFT+arrows | resize window |
| SUPER+G, ALT+Tab | toggle group, next in group |
| SUPER+Tab | swap split |
| SUPER+U / SUPER+CTRL+U | special workspace / move window there |
| SUPER+= / SUPER+- | cursor zoom in/out |
| SUPER+ALT+L | hyprlock |
| SUPER+N / SUPER+SHIFT+N | SwayNC panel / Do Not Disturb |
| SUPER+SHIFT+B | restart waybar |
| Print / SUPER+Print | screenshot to clipboard / to file (`simple-screenshot.sh`) |
| Brightness keys | `scripts/backlight.sh --inc/--dec` |
| Volume / mute / mic-mute keys | `scripts/volume.sh` |
| Media keys | `playerctl` |
| SUPER+Volume-up/down/mute | `smart-playerctl.sh` next / play-pause / previous |
| 3-finger horizontal swipe | switch workspace |

Before adding a binding, check that it's free:
`grep -n 'hl.bind' ~/.config/hypr/conf/keybindings.lua`.

### Autostart (`conf/autostart.lua`)

`swww-daemon` (+ restore wallpaper), `hypridle`, `swaync`,
`ags run ~/.config/ags --gtk 4`, `waybar`, `nm-applet`, `blueman-applet`,
`hyprpolkitagent`, `kdeconnectd`.

### Idle (`hypridle.conf`)

- 10 min: lock.
- 11 min: screen off (DPMS).
- 30 min: suspend.
- Locks before sleep.

`scripts/presentation-mode.sh` stops hypridle to turn this off, or starts it again.

---

## 6. Theme framework (`~/.config/hypr/colors`)

All colours come from one palette. **Don't hard-code colours in any themed app.**
Use the generated variables.

- **Palettes:** `themes/<name>/colors.sh` exports `COLOR_BACKGROUND`,
  `COLOR_FOREGROUND`, `COLOR_CURSOR`, `COLOR0`–`COLOR15`, `COLOR_ACCENT`,
  `COLOR_WARNING`, `COLOR_ERROR` and `COLOR_SUCCESS`.
  Available themes: `slate` (**active**), `catpuccin-frappe`, `antares`,
  `helly`, `wal` (generated from the wallpaper by pywal), `test`.
- **Apply a theme:** `~/.config/hypr/colors/generate-theme.sh <theme> [--hooks a,b]`.
  This links `current-theme/colors.sh` to the palette, then runs every
  `hooks/*.sh` through `utils/hook-framework.sh`.
- **How a hook works:** a hook sets `SYMLINK_TARGET` (a generated file in
  `current-theme/`) and `SYMLINK_SOURCE` (the path the app reads). It
  defines `hook_generate_target` to write the file from the colour variables,
  and `hook_post_generate` to reload the app. The framework then links source → target.

| Hook | App file (symlink) | Reload |
|---|---|---|
| `hyprland.sh` | `hypr/colors.conf` + `hypr/colors.lua` | `hyprctl reload` |
| `css.sh` | `waybar/colors.css` | restarts waybar |
| `wofi.sh` | `wofi/colors` | — |
| `kitty.sh` | `kitty/themes/mytheme.conf` | `kitty @ set-colors` |
| `swaync.sh` | `swaync/colors.css` | `swaync-client --reload-css` (only if running, with a timeout) |
| `ags.sh` | `ags/colors.css` (CSS vars `--osd-*`) | `ags request -i osd reload-css` |
| `firefox.sh` | `<firefox profile>/chrome/userChrome.css` | restart the browser |
| `mako.sh.disabled` | (Mako removed; hook disabled) | — |

- **Adding a themed app:** write a new `hooks/<app>.sh` that follows this pattern.
  The app's config should import or `@import` the generated colours file.
  Keep any reload in `hook_post_generate` non-blocking: guard it with `pgrep`
  and wrap it in `timeout`, because a hanging reload stalls the whole theme switch.
- **Wallpaper → theme:** `scripts/swww/set-wallpaper.sh <file>` sets the
  wallpaper (swww "grow" transition), then by default runs `scripts/wal.sh`
  and `generate-theme.sh wal`. `--disable-hooks` skips the colour change. The current
  wallpaper is cached in `~/.cache/wallpaper/current_wallpaper`.

---

## 7. Desktop components

### Waybar (`~/.config/waybar`)
- `config.jsonc` and `style.css` link to `themes/wal/`, the active theme.
  `theme-switcher.sh <theme>` changes those links. `colors.css` is generated.
- Modules:
  - Left: `hyprland/workspaces`, `wlr/taskbar`.
  - Centre: `clock`.
  - Right: `pulseaudio`, `battery`, `tray`, `custom/notification`.
  - A cava visualiser module exists, using `~/.config/cava/config-waybar`.
- `pulseaudio`: left-click toggles the AGS audio panel, right-click opens `pavucontrol`.
- `custom/notification`: the SwayNC bell (`swaync-client -swb`). Left-click opens the
  panel, right-click toggles Do Not Disturb.
- Restart with `killall waybar; hyprctl dispatch 'hl.dsp.exec_cmd("waybar")'`.

### SwayNC (`~/.config/swaync`)
- `config.json`:
  - Position top-right; panel width 420.
  - Timeouts: 5 s normal, 3 s low, critical never times out.
  - Widgets: title, dnd, mpris, notifications.
- `style.css` `@import`s `/etc/xdg/swaync/style.css` and the generated
  `colors.css`, then overrides with CSS variables. It's GTK4 CSS.
- Layer namespaces `swaync-notification-window` and `swaync-control-center`
  have slide animations in `windowrules.lua`.
- **Script convention:** OSD-type notifications from scripts use
  `notify-send -e -h boolean:SWAYNC_BYPASS_DND:true ...`. That makes them
  transient (not stored in the panel) and shows them even in Do Not Disturb.
- Useful commands:
  - `swaync-client -t -sw`: toggle the panel.
  - `-d -sw`: toggle Do Not Disturb.
  - `--reload-css`, `-R`: reload the config.
  - **`-C` clears all notifications. Don't run it casually.**
- Only one notification daemon can own D-Bus. Don't install or start Mako or dunst.

### AGS (`~/.config/ags`), instance `osd`
- AGS v3 (`aylurs-gtk-shell-git`), GTK4, TypeScript/JSX with gnim, and the Astal
  libraries (Wp/WirePlumber, Mpris, Apps).
- Files:
  - `app.ts`: request handler, and a runtime colours provider loaded from `colors.css`.
  - `widget/Osd.tsx`: the bottom-centre pill, in modes volume / mic / backlight / media.
    - Hovering keeps it open; a × closes it.
    - The slider can be dragged.
    - The media mode shows album art.
  - `widget/AudioCenter.tsx`: the audio panel (outputs, inputs, per-app volume),
    centred under the waybar volume module.
  - `style.scss`: uses only `var(--osd-*)` colours.
- **Requests:** `ags request -i osd <volume|mic|backlight|media [player]|audio|audio-close|reload-css>`.
- **Restart after code changes:** `ags quit -i osd` and then
  `hyprctl dispatch 'hl.dsp.exec_cmd("ags run ~/.config/ags --gtk 4")'`.
  SCSS and TSX are bundled at start-up, so editing them has no effect until a restart.
  `reload-css` reloads only the theme colours.
- **Don't** run `pkill -f "ags run"` from a shell whose own command line contains
  that string, because it kills itself. Use `ags quit -i osd`.
- Layer namespaces: `ags-osd` (slide from bottom) and `ags-audio` (no
  compositor animation; the panel animates itself).

### Wofi
`~/.config/wofi/config` (drun, 500x400, images) and `style.css`, plus the generated `colors`.

### Kitty
`~/.config/kitty/kitty.conf` includes the generated `themes/mytheme.conf`.

### Lock screen
`hyprlock.conf` (hyprlang) sources `hypr/colors.conf`, and shows the song and
battery from `scripts/song-status.sh` and `battery-status.sh`.

---

## 8. Scripts (`~/.config/hypr/scripts`)

| Script | What it does |
|---|---|
| `volume.sh --inc/--dec/--toggle-volume/--toggle-mic` | wpctl volume. Shows the AGS OSD, falling back to `notify-send` if AGS is down |
| `backlight.sh --inc/--dec` | brightnessctl. 3% steps; 1% steps at 4% and below; reaches 0% only from exactly 1%. Shows the AGS OSD |
| `smart-playerctl.sh next/play-pause/previous` | picks the right player; AGS media OSD |
| `battery-notify.sh <warning|critical|danger|charging> [level]` | batsignal notifications (critical urgency, icon, estimated time left; replaces the previous alert and closes it when charging starts) |
| `simple-screenshot.sh --copy/--save` | grim + slurp |
| `night-mode.sh`, `dark-mode.sh` | hyprsunset 4000K / hyprshade `dark` toggles |
| `presentation-mode.sh` | turns hypridle off or on |
| `swww/restore.sh`, `swww/set-wallpaper.sh`, `wal.sh` | wallpaper and pywal (section 6) |
| `hyprland-monitor-hook.sh` | socket listener (run by `monitor-hook.service`) |
| `vnc-server.sh` | headless output + wayvnc |
| `fzf-pacman*.sh`, `song-status.sh`, `battery-status.sh`, `network-status.sh` | helpers |
| `togglefloating.sh` | **old, uses the hyprlang syntax**; replaced by a Lua function in `keybindings.lua` |

Any new script that sends notifications should use the SwayNC hints from
section 7 and try the AGS OSD first.

---

## 9. Battery (batsignal)

`~/.config/batsignal` holds one argument per line. It sets:

- Battery `BAT0`.
- Levels: warning 15%, critical 7%, danger 3%.
- `-M` (a printf template, filled in as `'%s' %s`, i.e. message and level) runs `battery-notify.sh`.
- `-D` runs `battery-notify.sh danger`.
- `-p` gives charging and discharging messages.
- `-N` turns off batsignal's own notifications.

Restart with `systemctl --user restart batsignal`.

---

## 10. iPad as a second screen (Sunshine + ivm)

An iPad Air (5th gen) on USB-C works as an extended display. Sunshine streams a
virtual Hyprland output to the Moonlight app on the iPad, over a USB network
link. **ivm** ([ipad-virtual-monitor](https://github.com/diegostrg/ipad-virtual-monitor))
creates and removes that output.

### How it starts and stops (udev → systemd)

1. Plugging the iPad in: `usbmuxd-ncm` (AUR build of usbmuxd) switches it to
   USB mode 3, so it shows up as a `cdc_ncm` network device.
2. `/etc/udev/rules.d/79-ipad-usb.rules` (copy in `~/.config/udev/`, Apple vendor `05ac`) names the
   interfaces: USB interface 02 becomes **`ipad0`** (tethering, used by Moonlight), and interface
   04 becomes `ipadmux0` (NetworkManager ignores it). On `ipad0` it sets
   `SYSTEMD_USER_WANTS`, which starts both user units:
   `app-dev.lizardbyte.app.Sunshine.service` and `ivm-watch.service`.
3. Each unit has a drop-in `~/.config/systemd/user/<unit>.d/ipad.conf` with
   `BindsTo=sys-subsystem-net-devices-ipad0.device`. When the iPad is unplugged,
   the device goes away and systemd stops both units. Sunshine's drop-in also runs
   `ivm display remove` in `ExecStopPost`, so windows go back to `eDP-1`.
4. Both units are **disabled**. Nothing runs and nothing costs resources until the iPad is
   plugged in. Don't enable them, and don't add Sunshine to autostart.

### Pieces

| Piece | Where |
|---|---|
| Sunshine | `sunshine-bin` (AUR). The unit is from the package; it waits 5 s (`ExecStartPre`) before starting |
| Sunshine config | `~/.config/sunshine/sunshine.conf`: `capture = wlr`, `output_name = MOONLIGHT`, `global_prep_cmd` runs `ivm display prep` (creates the output when a client connects). Also `apps.json`, the logs (`sunshine.log*`) and the pairing `credentials` |
| ivm | Repo in `~/.local/share/ipad-virtual-monitor`; `~/.local/bin/ivm` links to `bin/ivm` |
| ivm config | `~/.config/ivm/config`: `WIDTH=2360 HEIGHT=1640 FPS=60 SCALE=1.67 SIDE=right` |
| ivm watch | `~/.config/systemd/user/ivm-watch.service`. A bash loop that polls every 2 s and removes the `MOONLIGHT` output after a grace period once the stream ends. Sunshine has no reliable disconnect hook, so this loop is needed |
| Network | NetworkManager connection `ipad-usb` on `ipad0`, `ipv4.method shared` (host `10.42.0.1/24`, DHCP to the iPad) |
| Firewall | ufw rules on `ipad0` only: udp 67 (DHCP), tcp 47984/47989/48010, udp 47998–48000 |
| Input | `/usr/lib/udev/rules.d/60-sunshine.rules` (from the package) gives access to uinput/uhid |

### Commands

- `ivm status`: the state of every layer. `ivm doctor`: says what's broken. Both are read-only.
- `ivm display status|create|remove`, `ivm net status`, `ivm down`, `ivm help <cmd>`.
- Logs: `journalctl --user -u app-dev.lizardbyte.app.Sunshine.service -u ivm-watch.service`,
  and `~/.config/sunshine/sunshine.log`.
- Check the udev side: `udevadm info /sys/class/net/ipad0 | grep -E 'SYSTEMD|NAME'`.

### Cost

Measured 2026-11-04 while streaming 2360x1640 at 60 fps:

- Sunshine: about 360 MB RSS (cgroup about 700 MB, peak 1.4 GB) and 22–26% of one core.
  Encoding is hardware `hevc_vaapi` on the Iris Xe. If the log shows a software encoder,
  something is wrong with VA-API.
- ivm watch: about 8 MB and close to 0% CPU.
- Nothing at all while the iPad is unplugged.

---

## 11. Dotfiles repository

- `~/.config` itself is the git repo: `git@github.com:Matteo-DP/Dotfiles.git`,
  branch `master`.
- **`.gitignore` uses a whitelist:** it ignores `/*` and then re-includes chosen
  paths with `!/path`. **A new top-level file or folder is not tracked until you add
  `!/name` to `.gitignore`.** To track only some files inside a folder, use
  the `!/dir/` + `/dir/*` + `!/dir/file` pattern, as for `gtk-3.0`, `gtk-4.0`,
  `htop` and `systemd/user`.
- Tracked:
  - `hypr`, `wofi`, `mako` (old), `swaync`, `ags`, `waybar`, `kitty`, `btop`,
    `cava`, `nwg-look`, `xsettingsd`, `zed`, `xournalpp`.
  - `mimeapps.list`, `batsignal`, `README.md`, `AGENTS.md`.
  - The `gtk-*/settings.ini` files, `htop/htoprc`, `systemd/user/monitor-hook.service`.
  - `udev/`: copies of the custom rules in `/etc/udev/rules.d`, with a README on how to install them.
  - iPad setup: `sunshine/sunshine.conf`, `sunshine/apps.json`, `ivm/config`,
    `systemd/user/ivm-watch.service`, and the `ipad.conf` drop-ins for it and Sunshine.
- `nvim` is a **git submodule** (`Matteo-DP/dotfiles-nvim`). It has its own repo
  and often has uncommitted changes there; leave those alone.
- Generated files (`hypr/colors/current-theme/*`) and app symlinks are part
  of the tracked trees. Expect them to change when the theme changes.
- Workflow: edit, test, then `git add <files>`. Don't commit.

---

## 12. Testing changes safely

- **Hyprland config:** after an edit, run `hyprctl reload`. Check for errors with
  `hyprctl configerrors`. Bad Lua can leave you with no keybindings, so test
  carefully.
- **Screenshots:** `grim -g "X,Y WxH" out.png` (the geometry is
  `x,y wxh`; mixing up `,` and `x` gives "invalid geometry"). Multi-monitor
  coordinates follow `hyprctl monitors`.
- **Pointer:** `hyprctl dispatch 'hl.dsp.cursor.move({ x = X, y = Y })'`.
  No click simulator is installed (no ydotool), so clicks can't be automated.
- **Notifications:** `notify-send -a Test "Title" "Body"`. Clean up test
  notifications afterwards, and remember they show up in the owner's panel.
- **Scripts:** run `bash -n script.sh` to check the syntax. For scripts that change
  hardware (backlight, volume), test the logic with stubbed functions instead of
  really changing the levels.
- **Audio:** don't raise the volume above the current level while testing; the
  owner may be wearing headphones.

---

## 13. Known pitfalls

- `hyprctl keyword` and old `hyprctl dispatch <name> <args>` syntax don't work
  any more (Lua config). Some old `.conf` files and scripts still contain it.
- `swaync-client` hangs if SwayNC isn't running. Always wrap it in
  `timeout` in hooks and scripts.
- AGS: `Gtk.Picture` ignores size limits; use `Gtk.Image` with `pixelSize`.
  Call `AstalMpris.get_default()` early, or the first media request sees no players.
- The keybinding `SUPER+CTRL+<number>` points to `$HYPRSCRIPTS/moveTo.sh`, which
  doesn't exist (it was already a no-op before the Lua move).
- `XF86Calculator` points to `~/.config/ml4w/...`, which doesn't exist (left over from ML4W).
- Hibernate isn't configured. Setting it up needs `resume=UUID=a6b5e7e7-8a94-4271-ae9d-e01ca4d6164f`
  in `GRUB_CMDLINE_LINUX_DEFAULT`, then `grub-mkconfig -o /boot/grub/grub.cfg`.
  The swap partition (20 GB) is big enough. Ask before changing it.
- zsh doesn't split unquoted variables into words the way bash does. Write
  scripts for `#!/bin/bash`, or loop with `while read`.
- The iPad drop-ins (`systemd/user/*.d/ipad.conf`) have comments that say
  `70-ipad-usb.rules`, but the real file is `79-ipad-usb.rules`.
  It must sort after `75-net-description.rules`, which sets the `ID_*` properties it matches on.
- udev rules live in `/etc/udev/rules.d/`. The repo keeps copies in `~/.config/udev/`;
  editing a copy does nothing until it is installed (`udev/README.md`). Keep the
  two copies in sync. `95-monitor-hotplug.rules` points to a unit that doesn't exist,
  so it has no effect.
  Never track `sunshine/credentials` or `sunshine/sunshine_state.json`: they hold
  pairing keys and the web UI password hash.
