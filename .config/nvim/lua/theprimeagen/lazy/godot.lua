return {
    "lommix/godot.nvim",
    lazy = true,
    cmd = { "GodotDebug", "GodotBreakAtCursor", "GodotStep", "GodotQuit", "GodotContinue" },
    opts = {
        bin = "godot", -- or "godot4" depending on your executable name

        dap = {
            host = "127.0.0.1",
            port = 6006,
        },

        gui = {
            console_config = {
                anchor = "SW",
                border = "double",
                col = 1,
                height = 10,
                relative = "editor",
                row = 99999,
                style = "minimal",
                width = 99999,
            },
        },

        expose_commands = true,
    },
}
