-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Restore default Vim behavior: delete into unnamed register
vim.keymap.set({ "n", "x" }, "d", "d", { desc = "Delete (unnamed register)" })
vim.keymap.set({ "n", "x" }, "c", "c", { desc = "Change (unnamed register)" })
vim.keymap.set({ "n", "x" }, "x", "x", { desc = "Delete char (unnamed register)" })
