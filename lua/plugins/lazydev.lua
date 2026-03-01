return {
  "folke/lazydev.nvim",
  ft = "lua",
  dependencies = {
    { "gonstoll/wezterm-types", lazy = true },
  },
  opts = {
    library = {
      "~/dev/projects/plugins/neovim",
      "~/dev/projects/plugins/wezterm",
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "LazyVim", words = { "LazyVim" } },
      { path = "wezterm-types", mods = { "wezterm" } },
      { path = "snacks.nvim", words = { "Snacks" } },
    },
  },
  enabled = function(root_dir)
    return vim.g.lazydev_enabled == nil and true
      or vim.g.lazydev_enabled
      or not vim.uv.fs_stat(root_dir .. "/.luarc.json")
  end,
}
