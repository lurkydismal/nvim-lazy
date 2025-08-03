-- ~/.config/nvim/lua/plugins/lsp/clangd.lua

return {
    setup = {
        clangd = function(_, opts)
            -- Customize opts here
            opts.cmd = { "clangd", "--header-insertion=never" }
            require("lspconfig").clangd.setup(opts)
            return true
        end,
    },
}
