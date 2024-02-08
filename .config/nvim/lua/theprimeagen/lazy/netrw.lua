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
