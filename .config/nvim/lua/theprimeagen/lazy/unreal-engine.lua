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
        -- Wayland fix: UnrealEditor launched via :UDEV run inherits nvim's env
        -- (UBT jobstart has no env hook). Force XWayland + neutralize HiDPI
        -- scale vars so the editor isn't bugged on Wayland compositors.
        for k, v in pairs({
            SDL_VIDEODRIVER             = "x11",
            QT_SCALE_FACTOR             = "unset",
            QT_AUTO_SCREEN_SCALE_FACTOR = "unset",
            GDK_SCALE                   = "unset",
            GDK_DPI_SCALE               = "unset",
        }) do
            vim.env[k] = v
        end

        require("UnrealDev").setup({
            -- Forwarded to UBT: default build/run target when no preset given
            -- and no bang picker used. Linux editor, Development config.
            engine_path = "/home/sleuth/UnrealEngine",
            preset_target = "LullabyEditor Linux Development",
            -- true = last bang-picked preset wins for plain commands this session;
            -- falls back to preset_target on a fresh session.
            use_last_preset_as_default = true,
            automation = {
                -- clangd reads compile_commands.json once at startup; without this
                -- a fresh DB is ignored until a manual :LspRestart.
                restart_lsp_after_gen_compile_db = true,
            },
        })

        -- UBT never regenerates the clang DB on its own, so new .cpp files land
        -- outside compile_commands.json and clangd loses every Unreal include for
        -- them. Re-run gen_compile_db whenever UCM adds/moves/renames a class.
        local unl_events = require("UNL.event.events")
        local unl_types = require("UNL.event.types")
        local pending = false
        for _, ev in ipairs({
            unl_types.ON_AFTER_NEW_CLASS_FILE,
            unl_types.ON_AFTER_MOVE_CLASS_FILE,
            unl_types.ON_AFTER_RENAME_CLASS_FILE,
            unl_types.ON_AFTER_DELETE_CLASS_FILE,
        }) do
            unl_events.subscribe(ev, function()
                -- Debounce: a move fires several events back to back.
                if pending then return end
                pending = true
                vim.defer_fn(function()
                    pending = false
                    require("UBT.api").gen_compile_db({})
                end, 1000)
            end)
        end
    end
}
