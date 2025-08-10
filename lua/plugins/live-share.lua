return {
    -- {
    --     "azratul/live-share.nvim",
    --     version = "v1.0.0",
    --     lazy = false, -- load immediately so commands are available
    --     config = function()
    --         require("live-share").setup({
    --             -- Optional config here, defaults are usually fine
    --         })
    --     end,
    -- },
    -- {
    --     "azratul/live-share.nvim",
    --     dependencies = {
    --         "jbyuki/instant.nvim",
    --     },
    --     config = function()
    --         vim.g.instant_username = "lurkydismal"
    --         require("live-share").setup({
    --             -- Add your configuration here
    --         })
    --     end,
    -- },
    {
        "jbyuki/instant.nvim",
        config = function()
            vim.g.instant_username = "lurkydismal"
        end,
    },
}
