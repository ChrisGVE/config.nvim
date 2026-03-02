return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = { enabled = true } } },
  },
  keys = {
    { "<leader>o", "", desc = "AI/OpenCode" },
    {
      "<leader>ot",
      function()
        require("opencode").toggle()
      end,
      desc = "Toggle opencode",
    },
    {
      "<leader>oa",
      function()
        require("opencode").ask()
      end,
      desc = "Ask opencode",
    },
    {
      "<leader>oa",
      function()
        require("opencode").ask("@selection: ")
      end,
      desc = "Ask about selection",
      mode = "v",
    },
    {
      "<leader>oA",
      function()
        require("opencode").ask("@cursor: ")
      end,
      desc = "Ask about cursor context",
    },
    {
      "<leader>oe",
      function()
        require("opencode").prompt("Explain @cursor and its context")
      end,
      desc = "Explain code at cursor",
    },
    {
      "<leader>on",
      function()
        require("opencode").command("session.new")
      end,
      desc = "New session",
    },
    {
      "<leader>oy",
      function()
        require("opencode").command("session.share")
      end,
      desc = "Share session",
    },
    {
      "<leader>os",
      function()
        require("opencode").select()
      end,
      desc = "Select prompt",
    },
    {
      "<leader>or",
      function()
        require("opencode").prompt("Review @file for bugs, improvements, and best practices")
      end,
      desc = "Review file",
    },
    {
      "<leader>of",
      function()
        require("opencode").prompt("Fix the diagnostics in @file")
      end,
      desc = "Fix diagnostics",
    },
    {
      "<leader>od",
      function()
        require("opencode").prompt("Add documentation to @cursor")
      end,
      desc = "Document code",
    },
    {
      "<leader>od",
      function()
        require("opencode").prompt("Add documentation to @selection")
      end,
      desc = "Document code",
      mode = "v",
    },
    {
      "<S-C-u>",
      function()
        require("opencode").command("session.half.page.up")
      end,
      desc = "Scroll messages up",
    },
    {
      "<S-C-d>",
      function()
        require("opencode").command("session.half.page.down")
      end,
      desc = "Scroll messages down",
    },
  },
  config = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "OpencodeEvent",
      callback = function(args)
        vim.notify(vim.inspect(args.data), vim.log.levels.DEBUG)
        if args.data.type == "session.idle" then
          vim.notify("opencode finished responding", vim.log.levels.INFO)
        end
      end,
    })

    vim.g.opencode_opts = {}
    vim.opt.autoread = true
  end,
}
