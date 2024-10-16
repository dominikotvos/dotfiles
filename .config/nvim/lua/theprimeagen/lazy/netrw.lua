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
        -- Define custom keybindings for when nvim-tree is attached
        local function on_attach(bufnr)
            local api = require('nvim-tree.api')

            -- Default keymaps
            api.config.mappings.default_on_attach(bufnr)

            -- Custom keybinding to expand all folders recursively within nvim-tree
            vim.keymap.set('n', 'R', api.tree.expand_all,
                { buffer = bufnr, noremap = true, silent = true, nowait = true })
        end

        require("nvim-tree").setup {
            on_attach = on_attach, -- Attach keybindings
            view = {
                side = 'right',
                width = 55,
            },
            renderer = {
                indent_markers = {
                    enable = true, -- Enable indent markers
                    icons = {
                        corner = "└ ",
                        edge = "│ ",
                        item = "│ ",
                        bottom = "─",
                        none = "  ",
                    },
                },
                indent_width = 1, -- Reduce the width of the indentation
            },
            diagnostics = {
                enable = true,
                icons = {
                    error = "",
                    warning = "",
                    info = "",
                    hint = "",
                }
            },
        }

        -- Move the keybinding to toggle NvimTree outside of on_attach, so it works globally
        vim.api.nvim_set_keymap("n", "<leader>E", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
    end,
}
