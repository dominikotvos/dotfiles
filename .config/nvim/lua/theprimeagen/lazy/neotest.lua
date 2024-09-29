return {
    -- {
    --     "nvim-neotest/neotest",
    --     dependencies = {
    --         "nvim-lua/plenary.nvim",
    --         "antoinemadec/FixCursorHold.nvim",
    --         "nvim-treesitter/nvim-treesitter",
    --         "marilari88/neotest-vitest",
    --         "nvim-neotest/neotest-plenary",
    --         "nvim-neotest/nvim-nio",
    --         "rcasia/neotest-java"
    --     },
    --     config = function()
    --         local neotest = require("neotest")
    --         neotest.setup({
    --             adapters = {
    --                 require("neotest-vitest"),
    --                 require("neotest-plenary").setup({
    --                     -- this is my standard location for minimal vim rc
    --                     -- in all my projects
    --                     min_init = "./scripts/tests/minimal.vim",
    --                 }),
    --                 require("neotest-java")({
    --                     ignore_wrapper = true
    --                 }),
    --             }
    --         })

    --         vim.keymap.set("n", "<leader>tc", function()
    --             neotest.run.run()
    --         end)

    --         vim.keymap.set("n", "<leader>tf", function()
    --             neotest.run.run(vim.fn.expand("%"))
    --         end)

    --         vim.keymap.set("n", "<leader>top", function()
    --             neotest.output_panel.toggle()
    --         end)

    --         vim.keymap.set("n", "<leader>ts", function()
    --             neotest.summary.toggle()
    --         end)

    --         vim.keymap.set("n", "<leader>tm", function()
    --             neotest.summary.marked()
    --         end)

    --         vim.keymap.set("n", "<leader>tr", function()
    --             neotest.summary.run_marked()
    --         end)

    --         vim.keymap.set("n", "<leader>tmc", function()
    --             neotest.summary.clear_marked()
    --         end)
    --     end,
    -- },
}
