-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Clear search highlights
map("n", "//", ":nohl<CR>", { desc = "Clear search results" })

-- Insert new line
map("n", "<cr>", "o<Esc>", { desc = "Insert blank line below" })

-- Visual mode moving blocks
map("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move block down" })
map("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move block up" })

-- Navigation putting the cursor in the middle of the screen
-- map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
-- map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
-- map("n", "<c-f>", "<c-f>zz", { desc = "page down" })
-- map("n", "<c-b>", "<c-b>zz", { desc = "page up" })
-- map("n", "k", "kzz", { desc = "Down" })
-- map("n", "j", "jzz", { desc = "Up" })
-- map("n", "n", "nzzzv", { desc = "Next search result" })
-- map("n", "N", "Nzzzv", { desc = "Previous search result" })
