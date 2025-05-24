return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      "~/dev/projects/plugins/neovim",
      "~/dev/projects/plugins/wezterm",
      { path = "LazyVim", words = { "LazyVim" } },
      { path = "wezterm-types", mods = { "wezterm" } },
    },
  },
  enabled = function(root_dir)
    return vim.g.lazydev_enabled == nil and true
      or vim.g.lazydev_enabled
      or not vim.uv.fs_stat(root_dir .. "/.luarc.json")
  end,
}
