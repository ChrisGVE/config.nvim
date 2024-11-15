return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  priority = 500,
  opts = {
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
      --     {
      --       name = "Lua",
      --       highlight = { sp = "cyan" },
      --       priority = 1,
      --       auto_close = true,
      --       matcher = function(buf)
      --         return buf.path:match("%.lua")
      --       end,
      --     },
      --     {
      --       name = "QMK",
      --       highlight = { sp = "violet" },
      --       priority = 1,
      --       auto_close = true,
      --       matcher = function(buf)
      --         return buf.path:match("%qmk%")
      --       end,
      --     },
      --     -- {
      --     --   name = "C",
      --     --   highlight = { sp = "orange" },
      --     --   priority = 1,
      --     --   auto_close = true,
      --     --   matcher = function(buf)
      --     --     return buf.path:match("%.h") or buf.path:match("%.c")
      --     --   end,
      --     -- },
      --     {
      --       name = "Docs",
      --       highlight = { sp = "green" },
      --       auto_close = true, -- whether or not close this group if it doesn't contain the current buffer
      --       priority = 2,
      --       matcher = function(buf)
      --         return buf.path:match("%.md") or buf.path:match("%.txt")
      --       end,
      --       separator = { -- Optional
      --         style = require("bufferline.groups").separator.tab,
      --       },
      --     },
      --     {
      --       name = "Tests", -- Mandatory
      --       highlight = { underline = true, sp = "blue" }, -- Optional
      --       priority = 3, -- determines where it will appear relative to other groups (Optional)
      --       icon = " ", -- Optional
      --       matcher = function(buf) -- Mandatory
      --         return buf.path:match("%_test") or buf.path:match("%_spec")
      --       end,
      --     },
      --   },
      -- },
    },
  },
}
