-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Clear search highlights
map("n", "//", ":nohl<CR>", { desc = "Clear search results" })

-- Insert new line
map("n", "<cr>", "o<Esc>", { desc = "Insert blank line below" })
map("n", "<S-cr>", "O<Esc>", { desc = "Insert blank line above" })
