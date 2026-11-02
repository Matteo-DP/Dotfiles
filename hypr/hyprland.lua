-- Main Hyprland config (Lua). Converted from hyprland.conf.
-- Each module lives in ./conf and is loaded in the same order as the old `source =` lines.
-- See https://wiki.hypr.land/Configuring/Start/

require("conf.variables")
require("conf.autostart")
require("conf.windowrules")
require("conf.keybindings")
require("conf.monitors")
require("conf.environment")
require("conf.permissions")
require("conf.animations")
require("conf.windows")
require("conf.decorations")
require("conf.input")
require("conf.custom")
require("conf.misc")
require("conf.layout")
