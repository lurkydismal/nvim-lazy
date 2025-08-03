return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                clangd = {
                    cmd = {
                        "clangd",
                        "--pch-storage=memory",
                        "--header-insertion=never",
                        "--index-store-path=/tmp/clangd-index",
                    },
                },
            },
        },
    },
}
