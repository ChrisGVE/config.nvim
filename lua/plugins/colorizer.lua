return {
  "catgoose/nvim-colorizer.lua",
  event = "BufReadPre",
  opts = {
    filetypes = {
      "*",
      "!markdown",
      lua = { mode = "background" },
      html = { mode = "background" },
      cmp_docs = { always_update = true },
    },
    buftypes = {},
    user_commands = true,
    lazy_load = false,
    options = {
      parsers = {
        css = true, -- preset: enables names, hex, rgb, hsl, oklch
        css_fn = true, -- preset: enables rgb, hsl, oklch
        names = {
          enable = true,
          lowercase = true,
          camelcase = true,
          uppercase = true,
          strip_digits = false,
          custom = false, -- table|function|false
        },
        hex = {
          default = true, -- default value for format keys (see above)
          rgb = true, -- #RGB
          rgba = true, -- #RGBA
          rrggbb = true, -- #RRGGBB
          rrggbbaa = true, -- #RRGGBBAA
          aarrggbb = true, -- 0xAARRGGBB
        },
        rgb = { enable = true },
        hsl = { enable = true },
        oklch = { enable = true },
        tailwind = {
          enable = true, -- parse Tailwind color names
          lsp = false, -- use Tailwind LSP documentColor
          update_names = false,
        },
        sass = {
          enable = true,
          parsers = { css = true },
          variable_pattern = "^%$([%w_-]+)",
        },
        xterm = { enable = true },
        custom = {},
      },
      display = {
        mode = "virtualtext", -- "background"|"foreground"|"virtualtext"
        background = {
          bright_fg = "#000000",
          dark_fg = "#ffffff",
        },
        virtualtext = {
          char = "■",
          position = "eol", -- "eol"|"before"|"after"
          hl_mode = "foreground",
        },
        priority = {
          default = 150, -- vim.hl.priorities.diagnostics
          lsp = 200, -- vim.hl.priorities.user
        },
      },
      hooks = {
        should_highlight_line = false, -- function(line, bufnr, line_num) -> bool
      },
      always_update = false,
    },
  },
}
