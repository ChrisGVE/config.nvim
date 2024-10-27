return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "polirritmico/telescope-lazy-plugins.nvim",
      "nvim-telescope/telescope-frecency.nvim",
      "benfowler/telescope-luasnip.nvim",
      "cagve/telescope-texsuite",
      "ghassan0/telescope-glyph.nvim",
      "xiyaowong/telescope-emoji.nvim",
      "nvim-telescope/telescope-symbols.nvim",
    },
    config = function()
      require("telescope").load_extension("lazy_plugins")
      require("telescope").load_extension("frecency")
      require("telescope").load_extension("luasnip")
      require("telescope").load_extension("texsuite")
      require("telescope").load_extension("glyph")
      require("telescope").load_extension("emoji")
    end,
  },
}
