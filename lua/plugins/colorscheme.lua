return {
    "folke/tokyonight.nvim",
    opts = {
        on_highlights = function(hl, colors)
            hl.LspInlayHint = {
                fg = "#dadada",
                bg = "#003f5f",
            }
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
            vim.schedule(function()
                vim.api.nvim_set_hl(0, "LspInlayHint", {
                    fg = "#545c7e",
                    bg = "#24283c",
                })
            end)
        end,
    },
}
