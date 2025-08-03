return {
    "folke/flash.nvim",
    opts = {
        modes = {
            char = {
                enabled = true,
            },
        },
    },
    keys = function()
        -- remove only the default `s` and `S` keymaps
        return {
            -- disable the stock `s` and `S`
            { "s", false, mode = { "n", "x", "o" } },
            { "S", false, mode = { "n", "x", "o" } },

            -- remap to Ctrl-s for flash.jump()
            {
                "<C-s>",
                function()
                    require("flash").jump()
                end,
                mode = { "n", "x", "o" },
                desc = "Flash jump",
            },
            -- remap to Ctrl-Shift-s for flash.treesitter()
            {
                "<C-S>",
                function()
                    require("flash").treesitter()
                end,
                mode = { "n", "x", "o" },
                desc = "Flash Treesitter",
            },
        }
    end,
}
