return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                clangd = {
                    cmd = {
                        "clangd",
                        "--clang-tidy",
                        "--pch-storage=memory",
                        "--header-insertion=never",
                        "--index-store-path=/tmp/clangd-index",
                    },
                },
            },
        },
    },
}
