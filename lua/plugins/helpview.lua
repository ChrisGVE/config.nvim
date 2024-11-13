return {
  "OXY2DEV/helpview.nvim",
  lazy = false,
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("helpview").setup()
  end,
}
