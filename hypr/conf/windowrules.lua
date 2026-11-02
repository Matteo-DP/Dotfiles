-----------------------------------------------------
-- Window rules
-----------------------------------------------------

hl.window_rule({ match = { class = "oyster-desktop" }, float = true })

hl.window_rule({ match = { title = "^(Extension: (Bitwarden Password Manager))" }, float = true })

hl.window_rule({ match = { class = ".*" }, focus_on_activate = true })

hl.layer_rule({ match = { namespace = "notifications" }, animation = "slide" })
hl.layer_rule({ match = { namespace = "selection" }, animation = "none" }) -- animations will show up on screenshot

-- Don't open fullscreen
hl.window_rule({ match = { class = "^libreoffice.*$" }, suppress_event = "maximize" })
hl.window_rule({ match = { class = "yaak-app" }, suppress_event = "maximize" })

hl.window_rule({ match = { class = "org.gnome.Calculator" }, float = true })

-- Fix some dragging issues with XWayland
-- hl.window_rule({
--     match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
--     no_focus = true,
-- })

hl.window_rule({ match = { class = ".*pavucontrol.*" }, float = true })
hl.window_rule({ match = { class = ".*pavucontrol.*" }, size = { 920, 680 } })

-- Floaters
hl.window_rule({ match = { class = "(?i)blueman-manager" }, float = true })
hl.window_rule({ match = { title = "^(nm-connection-editor)$" }, float = true })
hl.window_rule({ match = { title = "^(qalculate-gtk)$" }, float = true })
hl.window_rule({ match = { title = "nwg-look" }, float = true })
hl.window_rule({ match = { title = "nwg-displays" }, float = true })
hl.window_rule({ match = { title = "Select Move Destination" }, float = true })
hl.window_rule({ match = { title = "Select Extract Destination" }, float = true })
hl.window_rule({ match = { title = "Select Copy Destination" }, float = true })
hl.window_rule({ match = { title = "Open File" }, float = true })
hl.window_rule({ match = { title = "New Text Note — Okular" }, float = true })

-- Browser Picture in Picture
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, pin = true })
-- Was `move 69.5% 4%`; `move` takes expressions, so percentages are written against the monitor size.
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, move = { "monitor_w*0.695", "monitor_h*0.04" } })

-- Round when floating
hl.window_rule({ match = { float = true }, rounding = 15 })


-- No border on single window
-- hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
-- hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0 })

-- Fixes intellij tooltips
-- May match things that it shouldnt
-- hl.window_rule({ match = { class = "jetbrains-studio", float = true }, no_initial_focus = true })

-- Won't match unnecessairly
-- fix tooltips (always have a title of `win.<id>`)
hl.window_rule({ match = { class = "^(.*jetbrains.*)$", title = "^(win.*)$" }, no_initial_focus = true })
hl.window_rule({ match = { class = "^(.*jetbrains.*)$", title = "^(win.*)$" }, no_focus = true })
-- fix tab dragging (always have a single space character as their title)
hl.window_rule({ match = { class = "^(.*jetbrains.*)$", title = [[^\s$]] }, no_initial_focus = true })
hl.window_rule({ match = { class = "^(.*jetbrains.*)$", title = [[^\s$]] }, no_focus = true })

-- Prevent citrix bugs
hl.window_rule({ match = { title = "^(SOLIDWORKS)$" }, maximize = true })

hl.window_rule({ match = { title = "kitty-floating" }, float = true })
