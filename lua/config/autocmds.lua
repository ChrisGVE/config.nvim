-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
local map = vim.keymap.set

local group_id = vim.api.nvim_create_augroup("LuaReloadModule", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  group = group_id,
  pattern = "*.lua",
  callback = function()
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    -- Only reload if the first line is local M = {}
    if first_line and first_line:match("^local%s+M%s*=%s*{}") then
      local file_path = vim.fn.expand("%:p")
      local module_name = vim.fn.fnamemodify(file_path, ":.:r")

      package.loaded[module_name] = nil

      vim.notify("Module Reloaded:" .. module_name, nil, {
        title = "Notification",
        timeout = 500,
        render = "compact",
      })
    end
  end,
  desc = "Reload the current module on save",
})

vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter" }, {
  callback = function()
    vim.defer_fn(function()
      require("config.lsp_cleanup").should_run_cleanup(function(should_run)
        if should_run then
          require("config.lsp_cleanup").purge_old_lsp_logs(7)
        end
      end)
    end, 500) -- Delays execution slightly to avoid conflicts
  end,
  once = true,
})

-- Go support
-- Run gofmt+goimports on save
local format_sync_grp = vim.api.nvim_create_augroup("GoImports", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    require("go.format").goimports()
  end,
  group = format_sync_grp,
})
