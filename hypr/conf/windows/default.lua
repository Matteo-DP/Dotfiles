local colors = require("colors")

hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 6,

		border_size = 1,

		-- https://wiki.hypr.land/Configuring/Naming-conventions/#colors for info about colors
		col = {
			active_border = "rgb(" .. colors.COLOR_ACCENT .. ")",
			inactive_border = "rgb(" .. colors.COLOR8 .. ")",
		},

		-- Set to true enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = true,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = false,

		layout = "dwindle",
	},
})
