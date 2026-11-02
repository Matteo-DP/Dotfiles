-----------------------------------------------------
-- Key bindings
-- name: "Custom reduced keybinds"
-----------------------------------------------------

local vars = require("conf.variables")

-- SUPER KEY
local mainMod = "SUPER"
local SCRIPTS = "~/.config/hypr/scripts"

local function key(mods, k)
    if mods == "" then return k end
    return mods .. " + " .. k
end

-- Trackpad gestures
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Zoomin
-- Previously done through `hyprctl keyword`, which no longer works with a Lua config.
local function zoom(mult)
    local factor = hl.get_config("cursor.zoom_factor") * mult
    if factor < 1 then factor = 1 end
    hl.config({ cursor = { zoom_factor = factor } })
end
hl.bind(key(mainMod, "equal"), function() zoom(1.1) end, { repeating = true })
hl.bind(key(mainMod, "minus"), function() zoom(0.9) end, { repeating = true })

-- Applications
hl.bind(key(mainMod, "RETURN"), hl.dsp.exec_cmd(vars.term))
hl.bind(key(mainMod, "B"), hl.dsp.exec_cmd(vars.browser))
hl.bind(key(mainMod, "E"), hl.dsp.exec_cmd(vars.filemanager))

-- Toggle active window into floating mode.
-- Replaces scripts/togglefloating.sh (it used old `hyprctl dispatch` syntax):
-- tiled -> float, resize to 65% x 70% of the monitor, center. Floating -> tile.
local function toggle_floating()
    local w = hl.get_active_window()
    if w == nil then return end

    if w.floating then
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
        return
    end

    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    local m = hl.get_active_monitor()
    if m ~= nil then
        -- monitor width/height are in pixels; the old `%` was relative to the scaled (logical) size
        hl.dispatch(hl.dsp.window.resize({
            x = math.floor(m.width / m.scale * 0.65),
            y = math.floor(m.height / m.scale * 0.70),
        }))
    end
    hl.dispatch(hl.dsp.window.center())
end

-- Windows
hl.bind(key(mainMod, "Q"), hl.dsp.window.close()) -- Kill active window
hl.bind(key(mainMod, "F"), hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- Set active window to fullscreen
hl.bind(key(mainMod .. " + SHIFT", "F"), hl.dsp.window.fullscreen_state({ internal = 0, client = 2 })) -- fakefullscreen
hl.bind(key(mainMod, "M"), hl.dsp.window.fullscreen({ mode = "maximized" })) -- Maximize Window
hl.bind(key(mainMod, "T"), toggle_floating) -- Toggle active windows into floating mode
-- `workspaceopt allfloat` was removed from Hyprland (already a no-op in 0.56 hyprlang), no Lua equivalent:
-- hl.bind(key(mainMod .. " + SHIFT", "T"), ...) -- Toggle all windows into floating mode
hl.bind(key(mainMod .. " + ALT", "L"), hl.dsp.exec_cmd("hyprlock"))

-- hl.bind(key(mainMod, "TAB"), hl.dsp.layout("togglesplit")) -- Toggle split
hl.bind(key(mainMod, "Tab"), hl.dsp.layout("swapsplit")) -- Swapsplit

hl.bind(key(mainMod, "H"), hl.dsp.focus({ direction = "left" }))  -- Move focus left
hl.bind(key(mainMod, "L"), hl.dsp.focus({ direction = "right" })) -- Move focus right
hl.bind(key(mainMod, "K"), hl.dsp.focus({ direction = "up" }))    -- Move focus up
hl.bind(key(mainMod, "J"), hl.dsp.focus({ direction = "down" }))  -- Move focus down

hl.bind(key(mainMod .. " + SHIFT", "right"), hl.dsp.window.resize({ x = 100, y = 0, relative = true }))  -- Increase window width with keyboard
hl.bind(key(mainMod .. " + SHIFT", "left"), hl.dsp.window.resize({ x = -100, y = 0, relative = true })) -- Reduce window width with keyboard
hl.bind(key(mainMod .. " + SHIFT", "down"), hl.dsp.window.resize({ x = 0, y = 100, relative = true }))  -- Increase window height with keyboard
hl.bind(key(mainMod .. " + SHIFT", "up"), hl.dsp.window.resize({ x = 0, y = -100, relative = true }))   -- Reduce window height with keyboard

hl.bind(key(mainMod, "G"), hl.dsp.group.toggle()) -- Toggle tabbed window group
hl.bind(key("ALT", "TAB"), hl.dsp.group.next())

hl.bind(key(mainMod, "U"), hl.dsp.workspace.toggle_special()) -- Toggle special workspace
hl.bind(key(mainMod .. " + CTRL", "U"), hl.dsp.window.move({ workspace = "special" })) -- Move active window to special workspace

hl.bind(key(mainMod, "mouse:272"), hl.dsp.window.drag(), { mouse = true })   -- Move window with the mouse
hl.bind(key(mainMod, "mouse:273"), hl.dsp.window.resize(), { mouse = true }) -- Resize window with the mouse

-- Actions
-- TODO: make this save to file
hl.bind(key(mainMod, "PRINT"), hl.dsp.exec_cmd(SCRIPTS .. "/simple-screenshot.sh --save")) -- Take a screenshot
hl.bind("PRINT", hl.dsp.exec_cmd(SCRIPTS .. "/simple-screenshot.sh --copy"))
hl.bind(key(mainMod, "SPACE"), hl.dsp.exec_cmd(vars.menu))
hl.bind(key(mainMod, "N"), hl.dsp.exec_cmd("swaync-client -t -sw"))              -- Toggle notification center
hl.bind(key(mainMod .. " + SHIFT", "N"), hl.dsp.exec_cmd("swaync-client -d -sw")) -- Toggle do not disturb
-- hl.bind(key(mainMod .. " + SHIFT", "B"), hl.dsp.exec_cmd("~/.config/waybar/launch.sh")) -- Reload waybar
hl.bind(key(mainMod .. " + SHIFT", "B"), hl.dsp.exec_cmd("killall waybar && sleep 0.1 && waybar &"))
-- hl.bind(key(mainMod .. " + CTRL", "B"), hl.dsp.exec_cmd("~/.config/waybar/toggle.sh")) -- Toggle waybar
-- hl.bind(key(mainMod, "V"), hl.dsp.exec_cmd(SCRIPTS .. "/cliphist.sh")) -- Open clipboard manager
-- hl.bind(key(mainMod .. " + CTRL", "G"), hl.dsp.exec_cmd("$HYPRSCRIPTS/gamemode.sh")) -- Toggle game mode

hl.bind(key(mainMod .. " + CTRL + SHIFT", "l"), hl.dsp.workspace.move({ monitor = "r" }))
hl.bind(key(mainMod .. " + CTRL + SHIFT", "h"), hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(key(mainMod .. " + CTRL + SHIFT", "j"), hl.dsp.workspace.move({ monitor = "d" }))
hl.bind(key(mainMod .. " + CTRL + SHIFT", "k"), hl.dsp.workspace.move({ monitor = "u" }))

-- Workspaces
-- code:10 .. code:19 are the number row keys 1 .. 0
for i = 1, 10 do
    local code = "code:" .. (9 + i)
    hl.bind(key(mainMod, code), hl.dsp.focus({ workspace = i }))                      -- Open workspace i
    hl.bind(key(mainMod .. " + SHIFT", code), hl.dsp.window.move({ workspace = i }))  -- Move active window to workspace i
end

hl.bind(key(mainMod .. " + SHIFT", "l"), hl.dsp.focus({ workspace = "r+1" })) -- Open next workspace
hl.bind(key(mainMod .. " + SHIFT", "h"), hl.dsp.focus({ workspace = "r-1" })) -- Open previous workspace

-- Explanation for r, m: https://wiki.hypr.land/Configuring/Naming-conventions/#workspace-query
hl.bind(key(mainMod .. " + CTRL", "l"), hl.dsp.window.move({ workspace = "r+1" })) -- Move window to next workspace
hl.bind(key(mainMod .. " + CTRL", "h"), hl.dsp.window.move({ workspace = "r-1" })) -- Move window to previous workspace

-- Move all windows to workspace i.
-- NOTE: $HYPRSCRIPTS was never defined in the old config and moveTo.sh doesn't exist, so these did nothing before either.
for i = 1, 10 do
    hl.bind(key(mainMod .. " + CTRL", "code:" .. (9 + i)), hl.dsp.exec_cmd("$HYPRSCRIPTS/moveTo.sh " .. i))
end

-- hl.bind(key(mainMod, "mouse_down"), hl.dsp.focus({ workspace = "e+1" })) -- Open next workspace
-- hl.bind(key(mainMod, "mouse_up"), hl.dsp.focus({ workspace = "e-1" }))   -- Open previous workspace
-- hl.bind(key(mainMod .. " + CTRL", "down"), hl.dsp.focus({ workspace = "empty" })) -- Open the next empty workspace

-- Passthrough SUPER KEY to Virtual Machine
-- hl.bind(key(mainMod, "P"), hl.dsp.submap("passthru")) -- Passthrough SUPER key to virtual machine
-- hl.define_submap("passthru", function()
--     hl.bind("SUPER + Escape", hl.dsp.submap("reset")) -- Get SUPER key back from virtual machine
-- end)

-- Fn keys
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(SCRIPTS .. "/backlight.sh --inc"), { repeating = true })   -- Increase brightness by 10%
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(SCRIPTS .. "/backlight.sh --dec"), { repeating = true }) -- Reduce brightness by 10%
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(SCRIPTS .. "/volume.sh --inc"), { repeating = true })    -- Increase volume by 5%
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(SCRIPTS .. "/volume.sh --dec"), { repeating = true })    -- Reduce volume by 5%
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(SCRIPTS .. "/volume.sh --toggle-volume"))  -- Toggle mute
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))                  -- Audio play pause
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl pause"))                      -- Audio pause
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))                        -- Audio next
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))                    -- Audio previous
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(SCRIPTS .. "/volume.sh --toggle-mic")) -- Toggle microphone
hl.bind("XF86Calculator", hl.dsp.exec_cmd("~/.config/ml4w/settings/calculator.sh")) -- Open calculator
-- hl.bind("XF86Lock", hl.dsp.exec_cmd("hyprlock"))                                    -- Open screenlock

-- hl.bind("code:238", hl.dsp.exec_cmd("brightnessctl -d smc::kbd_backlight s +10"))
-- hl.bind("code:237", hl.dsp.exec_cmd("brightnessctl -d smc::kbd_backlight s 10-"))

-- Music control
hl.bind(key(mainMod, "XF86AudioRaiseVolume"), hl.dsp.exec_cmd(SCRIPTS .. "/smart-playerctl.sh next"))
hl.bind(key(mainMod, "XF86AudioLowerVolume"), hl.dsp.exec_cmd(SCRIPTS .. "/smart-playerctl.sh play-pause"))
hl.bind(key(mainMod, "XF86AudioMute"), hl.dsp.exec_cmd(SCRIPTS .. "/smart-playerctl.sh previous"))
