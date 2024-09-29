-- return {
--     "prichrd/netrw.nvim",
--     requires = {
--         'nvim-tree/nvim-web-devicons', -- optional
--     },
--     config = function()
--         require("netrw").setup({
--             color_icons = true;
--             default = true;
--         })
--     end
-- }
return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("nvim-tree").setup {
            view = {
                side = 'right',
                width = 55,
            },
            renderer = {
                indent_markers = {
                    enable = true,  -- Enable indent markers
                    icons = {
                        corner = "└ ",
                        edge = "│ ",
                        item = "│ ",
                        bottom = "─",
                        none = "  ",
                    },
                },
                indent_width = 1,  -- Reduce the width of the indentation
            },
            diagnostics = {
                enable = true,
                icons = {
                    error = "",
                    info = "",
                    hint = "",
                }
            },
        }
        -- Keybinding to toggle NvimTree
        vim.api.nvim_set_keymap("n", "<leader>E", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
    end,
}

