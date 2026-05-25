return {
    'taku25/UnrealDev.nvim',
    -- Trigger loading on C++ file types or with the UDEV command
    ft = { "cpp", "c" },
    cmd = { "UDEV" },

    dependencies = {
        -- Recommended UI plugins
        "j-hui/fidget.nvim",
        "nvim-telescope/telescope.nvim",

        -- Core UnrealDev plugins
        {
            'taku25/UNL.nvim',
            lazy = false,
            build = "cargo build --release --manifest-path scanner/Cargo.toml"
        }, -- Required
        {
            'taku25/UEP.nvim',
        },
        'taku25/UBT.nvim',
        'taku25/UCM.nvim',
        'taku25/USH.nvim',
        'taku25/ULG.nvim',
        {
            'taku25/UNX.nvim', -- Logical View
            dependencies = {
                "MunifTanjim/nui.nvim",
                "nvim-tree/nvim-web-devicons",
            },
        },

        -- Syntax and Parsers
        { 'taku25/USX.nvim', lazy = false }, -- Syntax highlighting
        {
            'romus204/tree-sitter-manager.nvim',
            opts = {
                ensure_installed = { "cpp", "ushader", "verse" },
                highlight        = { "cpp", "ushader", "verse" },
                border           = "rounded",
                languages        = {
                    cpp = {
                        install_info = {
                            url              = "https://github.com/taku25/tree-sitter-unreal-cpp",
                            -- Use tree-sitter-manager's full C++ queries; USX adds Unreal captures via after/queries.
                            use_repo_queries = false,
                        },
                    },
                    ushader = {
                        install_info = {
                            url              = 'https://github.com/taku25/tree-sitter-unreal-shader',
                            use_repo_queries = true,
                        },
                    },
                    verse = {
                        install_info = {
                            url              = 'https://github.com/taku25/tree-sitter-verse',
                            use_repo_queries = true,
                        },
                    },
                },
            },
            config = function(_, opts)
                vim.filetype.add({
                    extension = {
                        verse = "verse",
                        usf   = "ushader",
                        ush   = "ushader",
                    },
                })
                require("tree-sitter-manager").setup(opts)
                local group = vim.api.nvim_create_augroup('MyTreesitter', { clear = true })
                vim.api.nvim_create_autocmd('FileType', {
                    group    = group,
                    pattern  = opts.highlight,
                    callback = function(args)
                        vim.treesitter.start(args.buf)
                    end,
                })
            end,
        }
    },
    config = function()
        require("UnrealDev").setup({})
        -- Individual plugin settings can be configured here
        -- require('uep').setup { ... }
        -- require('ubt').setup { ... }
    end
}
