return {
    "folke/tokyonight.nvim",
    opts = {
        on_highlights = function(hl, colors)
            hl.LineNrAbove = {
                fg = "#ffffff",
            }
            hl.LineNrBelow = {
                fg = "#ffffff",
            }
            hl.Comment = {
                fg = "#00ffaa",
                italic = true,
            }
            hl.DiagnosticUnnecessary = {
                fg = vim.api.nvim_get_hl(0, { name = "Variable" }).fg,
                italic = true,
            }
        end,
    },
}
