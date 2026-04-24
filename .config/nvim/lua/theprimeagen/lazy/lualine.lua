return {
	"nvim-lualine/lualine.nvim",
	event = "ColorScheme",
	config = function()
		require("lualine").setup({
			options = {
				--- @usage 'rose-pine' | 'rose-pine-alt'
				theme = "auto"
			}
		})
	end
}
