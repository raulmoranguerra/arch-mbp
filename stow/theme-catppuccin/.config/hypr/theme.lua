-- Catppuccin Mocha: rounded corners, pink-to-black gradient border, wide gaps (hyprdots look)
hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 10,
		border_size = 2,
		col = {
			active_border = { colors = { "rgb(f5c2e7)", "rgb(cba6f7)" }, angle = 45 },
			inactive_border = { colors = { "rgb(242731)" } },
		},
	},
	decoration = {
		rounding = 10,
		blur = { enabled = false },
		shadow = { enabled = false },
	},
})
