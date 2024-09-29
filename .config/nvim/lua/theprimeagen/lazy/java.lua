return {
	{
		"mfussenegger/nvim-jdtls",
		ft = { "java" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
			local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspace/") .. project_name

			local config = {
				cmd = {
					"java",
					"-Declipse.application=org.eclipse.jdt.ls.core.id1",
					"-Dosgi.bundles.defaultStartLevel=4",
					"-Declipse.product=org.eclipse.jdt.ls.core.product",
					"-Dlog.protocol=true",
					"-Dlog.level=ALL",
					"-Xmx1g",
					"--add-modules=ALL-SYSTEM",
					"--add-opens", "java.base/java.util=ALL-UNNAMED",
					"--add-opens", "java.base/java.lang=ALL-UNNAMED",
					"-jar", vim.fn.expand(
					"~/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar"),
					"-configuration", vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls/config_linux"),
					"-data", workspace_dir,
				},
				root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "build.gradle" }),
				settings = { java = {} },
				init_options = { bundles = {} },
				capabilities = capabilities,
			}

			-- Auto-attach to Java files using autocommand
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "java",
				callback = function()
					require("jdtls").start_or_attach(config)
				end,
			})
			-- Keybindings for jdtls specific actions
			local opts = { noremap = true, silent = true }
			vim.api.nvim_set_keymap('n', '<leader>oi', '<Cmd>lua require("jdtls").organize_imports()<CR>', opts)
			vim.api.nvim_set_keymap('n', '<leader>ev', '<Cmd>lua require("jdtls").extract_variable()<CR>', opts)
			vim.api.nvim_set_keymap('v', '<leader>ev', '<Esc><Cmd>lua require("jdtls").extract_variable(true)<CR>', opts)
			vim.api.nvim_set_keymap('n', '<leader>ec', '<Cmd>lua require("jdtls").extract_constant()<CR>', opts)
			vim.api.nvim_set_keymap('v', '<leader>ec', '<Esc><Cmd>lua require("jdtls").extract_constant(true)<CR>', opts)
			vim.api.nvim_set_keymap('v', '<leader>em', '<Esc><Cmd>lua require("jdtls").extract_method(true)<CR>', opts)
		end,
	},
}
