local swift_filetypes = { "swift", "objc", "objcpp" }

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      local cmd = nil
      if vim.fn.executable("sourcekit-lsp") == 1 then
        cmd = { "sourcekit-lsp" }
      elseif vim.fn.executable("xcrun") == 1 then
        cmd = { "xcrun", "sourcekit-lsp" }
      end

      local sourcekit_opts = {
        filetypes = swift_filetypes,
      }
      if cmd then
        sourcekit_opts.cmd = cmd
      end

      opts.servers.sourcekit = vim.tbl_deep_extend("force", opts.servers.sourcekit or {}, sourcekit_opts)
    end,
  },
  {
    "wojciech-kulik/xcodebuild.nvim",
    ft = swift_filetypes,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {},
    keys = {
      { "<localleader>x", "", ft = swift_filetypes, desc = "Xcodebuild" },
      { "<localleader>xx", "<cmd>XcodebuildPicker<cr>", ft = swift_filetypes, desc = "Open Picker" },
      { "<localleader>xb", "<cmd>XcodebuildBuild<cr>", ft = swift_filetypes, desc = "Build" },
      { "<localleader>xr", "<cmd>XcodebuildRun<cr>", ft = swift_filetypes, desc = "Run" },
      { "<localleader>xt", "<cmd>XcodebuildTest<cr>", ft = swift_filetypes, desc = "Test" },
      { "<localleader>xS", "<cmd>XcodebuildSelectScheme<cr>", ft = swift_filetypes, desc = "Select Scheme" },
      { "<localleader>xD", "<cmd>XcodebuildSelectDevice<cr>", ft = swift_filetypes, desc = "Select Device" },
      { "<localleader>xL", "<cmd>XcodebuildToggleLogs<cr>", ft = swift_filetypes, desc = "Toggle Logs" },
      { "<localleader>xs", "<cmd>XcodebuildSetup<cr>", ft = swift_filetypes, desc = "Project Setup" },
    },
  },
}
