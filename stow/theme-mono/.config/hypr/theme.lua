-- Black and white: thin white focus border, square corners, no effects
hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 8,
		border_size = 1,
		col = {
			active_border = { colors = { "rgb(ffffff)" } },
			inactive_border = { colors = { "rgb(262626)" } },
		},
	},
	decoration = {
		rounding = 0,
		blur = { enabled = false },
		shadow = { enabled = false },
	},
})
