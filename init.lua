-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

require("lspconfig.configs").biome.manager.config.single_file_support = true
