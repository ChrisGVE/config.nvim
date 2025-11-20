return {
  "OXY2DEV/markview.nvim",
  lazy = false, -- false Recommended
  priority = 49,
  opts = {
    preview = {
      filetypes = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante", "codecompanion" },
      buf_ignore = {},
      ignore_buftypes = {},
    },
    max_length = 99999,
  },
  keys = {},
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
}
