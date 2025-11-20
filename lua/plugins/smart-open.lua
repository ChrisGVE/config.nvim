return {
  enabled = true,
  "danielfalk/smart-open.nvim",
  branch = "0.2.x",
  dependencies = {
    "kkharji/sqlite.lua",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  opts = {},
  keys = {
    {
      "<leader><leader>",
      function()
        require("telescope").extensions.smart_open.smart_open()
      end,
      desc = "Smart open",
    },
  },
}
