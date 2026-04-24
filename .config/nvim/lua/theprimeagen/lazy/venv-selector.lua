return {
--     'linux-cultist/venv-selector.nvim',
--     branch = "main",
--     dependencies = { 'neovim/nvim-lspconfig', 'nvim-telescope/telescope.nvim', 'mfussenegger/nvim-dap-python' },
--     -- Load earlier than 'VeryLazy' to ensure it's ready for null-ls
--     event = { "BufReadPre", "BufNewFile" },
--     opts = {
--         name = "venv",
--         auto_refresh = true,
--         dap_enabled = true,
--         notify_user_on_activate = true,
--         parents = 2,
--         search_venv_managers = true,
--         pipenv_path = vim.fn.expand("~/.local/bin/pipenv"),
--     },
--     keys = {
--         { '<leader>vs', '<cmd>VenvSelect<cr>',        desc = "Select Virtual Environment" },
--         { '<leader>vc', '<cmd>VenvSelectCached<cr>',  desc = "Select Cached Virtual Environment" },
--         { '<leader>vd', '<cmd>VenvSelectCurrent<cr>', desc = "Display Current Virtual Environment" },
--     },
--     config = function(_, opts)
--         -- Set up venv-selector
--         require("venv-selector").setup(opts)

--         -- Important: Trigger the custom event to notify null-ls that venv-selector is ready
--         vim.schedule(function()
--             vim.api.nvim_exec_autocmds("User", { pattern = "VenvSelectorLoaded" })
--         end)

--         -- Set up cache directory if it doesn't exist
--         local cache_dir = vim.fn.stdpath("cache") .. "/venv-selector"
--         if vim.fn.isdirectory(cache_dir) == 0 then
--             vim.fn.mkdir(cache_dir, "p")
--         end

--         -- Auto select venv when opening Python files
--         vim.api.nvim_create_autocmd("FileType", {
--             pattern = "python",
--             callback = function()
--                 -- Try to load cached venv, but don't show errors if not found
--                 pcall(function()
--                     vim.cmd("VenvSelectCached")

--                     -- After selection, notify again in case null-ls was loaded after this
--                     vim.schedule(function()
--                         vim.api.nvim_exec_autocmds("User", { pattern = "VenvSelectorLoaded" })
--                     end)
--                 end)
--             end
--         })

--         -- When a venv is selected, trigger the event again to refresh null-ls
--         vim.api.nvim_create_autocmd("User", {
--             pattern = "VenvActivated",
--             callback = function()
--                 vim.schedule(function()
--                     vim.api.nvim_exec_autocmds("User", { pattern = "VenvSelectorLoaded" })
--                 end)
--             end
--         })
--     end,
}
