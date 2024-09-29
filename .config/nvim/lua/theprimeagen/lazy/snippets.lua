return {
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp",

        dependencies = { "rafamadriz/friendly-snippets" },

        config = function()
            local ls = require("luasnip")
            local s = ls.snippet
            local t = ls.text_node
            local f = ls.function_node

            -- Extend JavaScript snippets to support JSDoc
            ls.filetype_extend("javascript", { "jsdoc" })

            -- Keybindings for snippet expansion and navigation
            vim.keymap.set({"i"}, "<C-s>e", function() ls.expand() end, {silent = true})

            vim.keymap.set({"i", "s"}, "<C-s>;", function() ls.jump(1) end, {silent = true})
            vim.keymap.set({"i", "s"}, "<C-s>,", function() ls.jump(-1) end, {silent = true})

            vim.keymap.set({"i", "s"}, "<C-E>", function()
                if ls.choice_active() then
                    ls.change_choice(1)
                end
            end, {silent = true})

            -- Java Snippets
            ls.add_snippets("java", {
                -- Logger snippet for SLF4J
                s("logger", {
                    t({"private static final Logger logger = LoggerFactory.getLogger("}),
                    f(function() return vim.fn.expand("%:t:r") end, {}), -- Dynamically insert the class name
                    t({".class);"})
                }),
            })
        end,
    }
}

