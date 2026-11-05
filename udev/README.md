# udev rules

These are the custom udev rules for this machine. udev reads them from
`/etc/udev/rules.d/`, which is outside the dotfiles repo, so this folder keeps the
copies under version control. **Changes made here do nothing until you install them.**

## Rules

### `79-ipad-usb.rules`: iPad as a second screen

Goal: run the iPad screen setup (Sunshine and `ivm watch`) only while the iPad
is plugged in, and give its USB network interfaces fixed names.

- It matches Apple devices (vendor `05ac`) that `usbmuxd-ncm` has switched to USB
  mode 3. In that mode the iPad shows up as a `cdc_ncm` network device.
- It names the interfaces the same way on every USB port:
  - USB interface 02 becomes `ipad0`, the tethering network that Moonlight uses. The
    NetworkManager connection `ipad-usb` (shared, `10.42.0.1/24`) and the ufw rules
    are tied to this name.
  - USB interface 04 becomes `ipadmux0`, Apple's private multiplexor. It is marked
    `NM_UNMANAGED`, so NetworkManager leaves it alone.
- On `ipad0` it sets `SYSTEMD_USER_WANTS`. That starts
  `app-dev.lizardbyte.app.Sunshine.service` and `ivm-watch.service` in the user
  session.
- Stopping on unplug is not done here. The units'
  `~/.config/systemd/user/<unit>.d/ipad.conf` drop-ins have
  `BindsTo=sys-subsystem-net-devices-ipad0.device`, so systemd stops the units when the
  interface goes away.
- The number 79 matters. The rule must run after `75-net-description.rules`,
  which sets the `ID_*` properties it matches on, and before
  `80-net-setup-link.rules`, which would otherwise name the interface.
- There is no `ACTION=="add"` condition, on purpose. Renaming the interface fires a
  `move` event, and the properties have to survive that event.

See section 10 of `~/.config/AGENTS.md` for the whole setup.

### `95-monitor-hotplug.rules`: not used

Goal (originally): start a user unit `monitor-hotplug@<card>.service` when a DRM
connector reports a hotplug.

**No `monitor-hotplug@.service` unit exists, so this rule has no effect.**
Restoring the wallpaper when a monitor is plugged in is handled by
`monitor-hook.service` (`hypr/scripts/hyprland-monitor-hook.sh`), which listens on the
Hyprland socket instead. It is kept here for reference. You can remove it from
`/etc` with `sudo rm /etc/udev/rules.d/95-monitor-hotplug.rules`.

## Install

Install or update one rule, then reload udev:

```sh
sudo install -m 644 -o root -g root ~/.config/udev/79-ipad-usb.rules /etc/udev/rules.d/
sudo udevadm control --reload
```

The rules apply to new events only. To apply the iPad rule now, unplug and replug
the iPad, or run:

```sh
sudo udevadm trigger --subsystem-match=net --action=add
```

Check the result with the iPad plugged in:

```sh
udevadm info /sys/class/net/ipad0 | grep -E 'NAME|SYSTEMD_USER_WANTS'
systemctl --user status app-dev.lizardbyte.app.Sunshine.service ivm-watch.service
```

Test a rule without applying it: `udevadm test /sys/class/net/ipad0`.

## Keeping the copies in sync

The installed rule in `/etc` is the one udev uses. After you edit a rule in either
place, check that the two copies still match:

```sh
diff ~/.config/udev/79-ipad-usb.rules /etc/udev/rules.d/79-ipad-usb.rules
```
