return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "danielfalk/smart-open.nvim",
  },
  config = function()
    local telescope = require("telescope")
    -- setup smart-open
    telescope.setup({
      extensions = {
        smart_open = {
          match_algorithm = "fzf",
          show_scores = true,
        },
      },
    })
  end,
}
