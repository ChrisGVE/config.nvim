-- Listen for opencode events
vim.api.nvim_create_autocmd("User", {
  pattern = "OpencodeEvent",
  callback = function(args)
    -- See the available event types and their properties
    vim.notify(vim.inspect(args.data), vim.log.levels.DEBUG)
    -- Do something interesting, like show a notification when opencode finishes responding
    if args.data.type == "session.idle" then
      vim.notify("opencode finished responding", vim.log.levels.INFO)
    end
  end,
})

return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for better prompt input, and required to use `opencode.nvim`'s embedded terminal — otherwise optional
    { "folke/snacks.nvim", opts = { input = { enabled = true } } },
  },
  keys = {
    { "_a", "", desc = "AI Menu" },
    {
      "_at",
      function()
        require("opencode").toggle()
      end,
      desc = "Toggle opencode",
    },
    {
      "_aA",
      function()
        require("opencode").ask()
      end,
      desc = "Ask opencode",
    },
    {
      "_aa",
      function()
        require("opencode").ask("@cursor: ")
      end,
      desc = "Ask opencode about this",
    },
    {
      "_ae",
      function()
        require("opencode").prompt("Explain @cursor and its context")
      end,
      desc = "Explain this code",
    },
    {
      "_aa",
      function()
        require("opencode").ask("@selection: ")
      end,
      desc = "Ask opencode about selection",
      mode = "v",
    },
    {
      "_an",
      function()
        require("opencode").command("session_new")
      end,
      desc = "New opencode session",
    },
    {
      "_ay",
      function()
        require("opencode").command("messages_copy")
      end,
      desc = "Copy last opencode response",
    },
    {
      "<s-C-u>",
      function()
        require("opencode").command("messages_half_page_up")
      end,
      desc = "Messages half page up",
    },
    {
      "<s-C-d>",
      function()
        require("opencode").command("messages_half_page_down")
      end,
      desc = "messages half page up",
    },
    {
      "_as",
      function()
        require("opencode").select()
      end,
      desc = "Select opencode prompt",
    },
  },
  config = function()
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`
    }

    -- Required for `opts.auto_reload`
    vim.opt.autoread = true
  end,
}
