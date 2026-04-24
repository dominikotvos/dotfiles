return {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
    },
    config = function()
        -- Setup fold options (required for UFO)
        vim.o.foldcolumn = "1"
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        -- Custom fold text handler to show line count
        local handler = function(virtText, lnum, endLnum, width, truncate)
            local newVirtText = {}
            local suffix = (" 󰁂 %d "):format(endLnum - lnum)
            local sufWidth = vim.fn.strdisplaywidth(suffix)
            local targetWidth = width - sufWidth
            local curWidth = 0
            for _, chunk in ipairs(virtText) do
                local chunkText = chunk[1]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, targetWidth - curWidth)
                    local hlGroup = chunk[2]
                    table.insert(newVirtText, { chunkText, hlGroup })
                    chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if curWidth + chunkWidth < targetWidth then
                        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                    end
                    break
                end
                curWidth = curWidth + chunkWidth
            end
            table.insert(newVirtText, { suffix, "MoreMsg" })
            return newVirtText
        end

        require("ufo").setup({
            provider_selector = function(bufnr, filetype, buftype)
                return { "treesitter", "indent" }
            end,
            fold_virt_text_handler = handler,
            close_fold_kinds_for_ft = {
                default = { "imports", "comment" },
            },
            preview = {
                win_config = {
                    border = "rounded",
                    winblend = 12,
                    winhighlight = "Normal:Normal",
                    maxheight = 20,
                },
                mappings = {
                    scrollU = "<C-u>",
                    scrollD = "<C-d>",
                    jumpTop = "[",
                    jumpBot = "]",
                },
            },
        })

        -- Remap native fold commands to UFO enhanced versions
        vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
        vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })

        -- UFO-specific features with <leader>z prefix
        vim.keymap.set("n", "<leader>zp", function()
            local winid = require("ufo").peekFoldedLinesUnderCursor()
            if not winid then
                vim.lsp.buf.hover()
            end
        end, { desc = "Peek fold" })

        vim.keymap.set("n", "<leader>zE", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
        vim.keymap.set("n", "<leader>zL", function()
            require("ufo").closeFoldsWith(1)
        end, { desc = "Close folds with level" })
    end,
}
