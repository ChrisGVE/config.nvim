return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    dashboard = {
      sections = {
        {
          section = "terminal",
          cmd = "figlet -f ~/.config/figlet_custom/ansi_shadow 'LAZYVIM' | lolcat -F 0.3 -t -p 100 -f",
          height = 6,
          padding = 1,
          align = "center",
        },
        function()
          local ok, taskforge = pcall(require, "taskforge")
          if ok and taskforge.get_dashboard_section then
            vim.notify("Taskforge dashboard section loaded")
            local section = taskforge.get_dashboard_section()
            if section and #section > 0 then
              vim.notify("Taskforge section has " .. #section .. " items")
              return section
            else
              vim.notify("Taskforge section is empty")
              return {
                {
                  icon = " ",
                  title = "Tasks (Fallback)",
                  pane = 2,
                },
                {
                  pane = 2,
                  padding = 1,
                  indent = 3,
                  text = {
                    { "No tasks available", hl = "special" },
                  },
                  height = 3,
                },
              }
            end
          else
            vim.notify("Taskforge not available for dashboard")
            return {}
          end
        end,
        -- function()
        --   return require("taskforge.dashboard").create_section()
        -- end,
        { icon = " ", title = "Keymaps", section = "keys", indent = 3, gap = 1, padding = 1, pane = 1 },
        { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 3, padding = 1 },
        { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 3, padding = 1 },
        {
          pane = 2,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "hub status --short --branch --renames",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        },
        { section = "startup", pane = 2 },
      },
    },
    zen = {},
    dim = {},
    indent = {},
    input = {},
    scope = {},
    scroll = {},
    animate = {},
    bigfile = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    words = { enabled = true },
    statuscolumn = { enabled = true },
    styles = {
      notification = {
        wo = { wrap = true }, -- Wrap notifications
      },
    },
  },
  keys = {
    { "<leader>n", "", desc = "notifications" },
    { "<leader>nh", "<cmd>lua Snacks.notifier.show_history()<cr>", desc = "history" },
    {
      "<leader>nN",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    },
  },
}
