-- TODO: Fix both
return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                biome = {
                    workspace_required = false,
                    single_file_support = true,
                },
            },
        },
    },
}
