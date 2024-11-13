-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.maplocalleader = " "
vim.g.mapleader = "\\"

vim.opt.winbar = "%=%m %f"
vim.g.simple_todo_map_keys = 0

vim.g.python3_host_prog = "/usr/local/Caskroom/miniconda/base/envs/pynvim/bin/python"

vim.g.lazyvim_prettier_needs_config = false

vim.opt_global.scrolloff = 999

vim.o.termguicolors = true

vim.o.mousemoveevent = true
