return {
  "linux-cultist/venv-selector.nvim",
  branch = "regexp", -- Use this branch for the new version
  cmd = "VenvSelect",
  enabled = function()
    return LazyVim.has("telescope.nvim")
  end,
  event = "VeryLazy",
  opts = {
    settings = {
      search = {
        miniconda_envs = {
          command = "fd bin/python$ /usr/local/Caskroom/miniconda/base/envs --full-path --color never",
          type = "anaconda",
        },
        miniconda_base = {
          command = "fd /python$ /usr/local/Caskroom/miniconda/base/bin --full-path --color never",
          type = "anaconda",
        },
      },
      options = {
        notify_user_on_venv_activation = true,
      },
    },
  },
  --  Call config for python files and load the cached venv automatically
  ft = "python",
  keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
}
