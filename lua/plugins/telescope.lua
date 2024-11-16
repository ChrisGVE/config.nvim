return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "polirritmico/telescope-lazy-plugins.nvim",
      "nvim-telescope/telescope-frecency.nvim",
      "benfowler/telescope-luasnip.nvim",
      "ghassan0/telescope-glyph.nvim",
      "xiyaowong/telescope-emoji.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      "tsakirist/telescope-lazy.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-project.nvim",
      "nvim-telescope/telescope-bibtex.nvim",
    },
    config = function()
      require("telescope").load_extension("lazy_plugins")
      require("telescope").load_extension("frecency")
      require("telescope").load_extension("luasnip")
      require("telescope").load_extension("glyph")
      require("telescope").load_extension("emoji")
      require("telescope").load_extension("lazy")
      require("telescope").load_extension("file_browser")
      require("telescope").load_extension("project")
      require("telescope").load_extension("projects") -- this is for project.nvim
      require("telescope").load_extension("bibtex")
    end,
  },
}
