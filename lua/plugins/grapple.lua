return {
  "cbochs/grapple.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons", lazy = true },
  },
  opts = {
    scope = "git",
    icons = true,
    status = true,
  },
  keys = {
    { "<leader>1", "<cmd>Grapple select index=1<cr>", desc = "Grapple to file 1" },
    { "<leader>2", "<cmd>Grapple select index=2<cr>", desc = "Grapple to file 2" },
    { "<leader>3", "<cmd>Grapple select index=3<cr>", desc = "Grapple to file 3" },
    { "<leader>4", "<cmd>Grapple select index=4<cr>", desc = "Grapple to file 4" },
    { "<leader>5", "<cmd>Grapple select index=5<cr>", desc = "Grapple to file 5" },
    { "<leader>h", "<cmd>Grapple tag<cr>", desc = "Grapple tag" },
    { "<leader>H", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple tag menu" },
    { "<M-g>", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle to next tag" },
    { "<s-M-g>", "<cmd>Grapple cycle_scopes next<cr>", desc = "Grapple cycle to next scope" },
    { "<M-s>", "<cmd>Grapple toggle_scopes<cr>", desc = "Grapple scope menu" },
    { "<M-q>", "<cmd>Grapple quickfix<cr>", desc = "Grapple open quickfix" },
    { "<M-f>", "<cmd>Grapple find<cr>", desc = "Grapple find" },
  },
}
