return {
    "prichrd/netrw.nvim",
    requires = {
        'nvim-tree/nvim-web-devicons', -- optional
    },
    config = function()
        require("netrw").setup({
            color_icons = true;
            default = true;
        })
    end
}
-- return {
--     "nvim-tree/nvim-tree.lua",
--     version = "*",
--     lazy = false,
--     dependencies = {
--         "nvim-tree/nvim-web-devicons",
--     },
--     config = function()
--         require("nvim-tree").setup {
--             view = {
--                 side = 'right',
--                 width = 30,
--             },
--             diagnostics = {
--                 enable = true,
--                 icons = {
--                     error = "",
--                     info = "",
--                     hint = "",
--                 }
--             },
--         }
--         vim.api.nvim_set_keymap("n", "<leader>E", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
--     end,
-- }
