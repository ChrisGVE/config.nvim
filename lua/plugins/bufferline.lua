-- change the appearance of the bufferline
-- local mocha = require("catppuccin.palettes").get_palette("mocha")
-- local macchiato = require("catppuccin.palettes").get_palette("macchiato")
-- local frappe = require("catppuccin.palettes").get_palette("frappe")
-- local latte = require("catppuccin.palettes").get_palette("latte")
local colors = require("catppuccin.palettes").get_palette()

return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  keys = {
    { "gB", "<cmd>BufferLinePick<CR>", desc = "Pick a buffer" },
    { "gC", "<cmd>BufferLinePickClose<CR>", desc = "Pick a buffer and close it" },
  },
  opts = {
    highlights = require("catppuccin.groups.integrations.bufferline").get({
      custom = {
        all = {
          buffer_selected = { bg = colors.surface0 },
          duplicate_selected = { bg = colors.surface0 },
          tab_selected = { bg = colors.surface0 },
          tab_separator_selected = { bg = colors.surface0 },
          indicator_selected = { bg = colors.surface0 },
          separator_selected = { bg = colors.surface0 },
          close_button_selected = { fg = colors.peach, bg = colors.surface0 },
          numbers_selected = { bg = colors.surface0 },
          error_selected = { bg = colors.surface0 },
          error_diagnostic_selected = { bg = colors.surface0 },
          warning_selected = { bg = colors.surface0 },
          info_selected = { bg = colors.surface0 },
          info_diagnostic_selected = { bg = colors.surface0 },
          hint_selected = { bg = colors.surface0 },
          hint_diagnostic_selected = { bg = colors.surface0 },
          diagnostic_selected = { bg = colors.surface0 },
          modified_selected = { bg = colors.surface0 },
        },
      },
    }),
    options = {
      separator_style = "slope",
      hover = {
        enabled = true,
        delay = 200,
        reveal = { "close" },
      },
      numbers = function(opts)
        return string.format("%s|%s", opts.id, opts.raise(opts.ordinal))
      end,
      sort_by = function(buffer_a, buffer_b)
        return buffer_a.path < buffer_b.path
      end,
      -- groups = {
      --   options = {
      --     toggle_hidden_on_enter = true,
      --   },
      --   items = {
      --     require("bufferline.groups").builtin.ungrouped,
      --     {
      --       name = "Lua",
      --       highlight = { sp = colors.sky },
      --       auto_close = true,
      --       matcher = function(buf)
      --         return buf.path:match("%.lua")
      --       end,
      --     },
      --     {
      --       name = "Python",
      --       highlight = { sp = colors.blue },
      --       auto_close = true,
      --       matcher = function(buf)
      --         return buf.path:match("%.py")
      --       end,
      --     },
      --     {
      --       name = "C/C++",
      --       highlight = { sp = colors.peach },
      --       auto_close = true,
      --       matcher = function(buf)
      --         return buf.path:match("%.c") or buf.path:match("%.h") or buf.path:match("%.cpp")
      --         -- or buf.path:match("%.hpp")
      --       end,
      --     },
      --     {
      --       name = "Docs",
      --       highlight = { sp = colors.green },
      --       auto_close = true, -- whether or not close this group if it doesn't contain the current buffer
      --       matcher = function(buf)
      --         return buf.path:match("%.md") or buf.path:match("%.txt")
      --       end,
      --     },
      --     {
      --       name = "Tests", -- Mandatory
      --       highlight = { underline = true, sp = colors.maroon }, -- Optional
      --       icon = " ", -- Optional
      --       auto_close = true,
      --       matcher = function(buf) -- Mandatory
      --         return buf.path:match("%_test") or buf.path:match("%_spec")
      --       end,
      --     },
      --   },
      -- },
    },
  },
}
