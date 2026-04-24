return {

    {
        "nvim-lua/plenary.nvim",
        name = "plenary",
    },

    "eandrju/cellular-automaton.nvim",

    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },

    {
        "aurum77/live-server.nvim",
        run = function()
            require("live_server.util").install()
        end,
        cmd = { "LiveServer", "LiveServerStart", "LiveServerStop" },
    },

    "shumphrey/fugitive-gitlab.vim",
    "tpope/vim-rhubarb",
    "tpope/vim-commentary",
    "tpope/vim-surround",
    "tpope/vim-repeat",
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {}, -- this is equalent to setup({}) function
    },
    {
        "z0mbix/vim-shfmt",
        ft = { "sh" },
    },
    {
        "andweeb/presence.nvim",
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
    },
    {
        "adelarsq/image_preview.nvim",
        event = "VeryLazy",
        config = function()
            require("image_preview").setup()
        end,
    },
}
