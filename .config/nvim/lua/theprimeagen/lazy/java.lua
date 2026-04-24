return {
    {
        'mfussenegger/nvim-jdtls',
        ft = { "java" },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Function to start JDTLS
            local function start_jdtls()
                local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
                local workspace_base = vim.fn.expand("~/.cache/jdtls/workspace/")
                local workspace_dir = workspace_base .. project_name
                if vim.fn.isdirectory(workspace_dir) == 0 then
                    vim.fn.mkdir(workspace_dir, "p")
                end

                local root_dir = require("jdtls.setup").find_root({
                    ".git", "gradlew", "mvnw", "build.gradle", "pom.xml"
                })
                if not root_dir then
                    vim.notify("JDTLS: Could not find project root", vim.log.levels.ERROR)
                    return
                end

                local config = {
                    cmd = {
                        "jdtls",
                        "--jvm-arg=-javaagent:/usr/share/java/lombok/lombok.jar",
                        "-data", workspace_dir,
                    },
                    root_dir = root_dir,
                    settings = {
                        java = {
                            configuration = {
                                runtimes = {
                                    { name = "JavaSE-21", path = "/usr/lib/jvm/java-21-temurin/" },
                                },
                            },
                        },
                    },
                    init_options = { bundles = {} },
                    capabilities = capabilities,
                }

                require("jdtls").start_or_attach(config)

                -- Keymaps
                local opts = { noremap = true, silent = true }
                vim.keymap.set('n', '<leader>oi', require("jdtls").organize_imports, opts)
                vim.keymap.set('n', '<leader>ev', require("jdtls").extract_variable, opts)
                vim.keymap.set('v', '<leader>ev', function() require("jdtls").extract_variable(true) end, opts)
                vim.keymap.set('n', '<leader>ec', require("jdtls").extract_constant, opts)
                vim.keymap.set('v', '<leader>ec', function() require("jdtls").extract_constant(true) end, opts)
                vim.keymap.set('v', '<leader>em', function() require("jdtls").extract_method(true) end, opts)
                vim.keymap.set('n', '<leader>fu', '<Cmd>Telescope lsp_references<CR>', opts)
            end

            -- Autostart JDTLS for each Java buffer
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "java",
                callback = start_jdtls,
            })
        end,
    },
}
