local function run_task(task_def)
  local ok, overseer = pcall(require, "overseer")
  if not ok then
    vim.notify("overseer.nvim is not available", vim.log.levels.WARN)
    return
  end

  local task = overseer.new_task(task_def)
  task:start()
  overseer.open({ enter = false })
end

local function run_qmk(action)
  if vim.fn.executable("qmk") ~= 1 then
    vim.notify("qmk CLI is not available in PATH", vim.log.levels.WARN)
    return
  end

  vim.ui.input({
    prompt = "QMK keyboard (e.g. keychron/q1/rev_1): ",
  }, function(keyboard)
    if not keyboard or keyboard == "" then
      return
    end

    vim.ui.input({
      prompt = "QMK keymap [default]: ",
    }, function(keymap)
      local resolved_keymap = (keymap and keymap ~= "") and keymap or "default"
      local args = { action, "-kb", keyboard, "-km", resolved_keymap }

      run_task({
        name = ("qmk %s %s:%s"):format(action, keyboard, resolved_keymap),
        cmd = "qmk",
        args = args,
        cwd = vim.fn.getcwd(),
        components = { "default", "on_output_quickfix" },
      })
    end)
  end)
end

return {
  "stevearc/overseer.nvim",
  cmd = {
    "OverseerOpen",
    "OverseerClose",
    "OverseerToggle",
    "OverseerRun",
    "OverseerShell",
    "OverseerTaskAction",
  },
  keys = {
    { "<leader>r", "", desc = "Run/Tasks" },
    { "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Run Task" },
    { "<leader>rs", "<cmd>OverseerShell<cr>", desc = "Run Shell Task" },
    { "<leader>rt", "<cmd>OverseerToggle<cr>", desc = "Toggle Tasks" },
    { "<leader>ra", "<cmd>OverseerTaskAction<cr>", desc = "Task Action" },
    {
      "<leader>rq",
      function()
        run_qmk("compile")
      end,
      desc = "QMK Compile",
    },
    {
      "<leader>rQ",
      function()
        run_qmk("flash")
      end,
      desc = "QMK Flash",
    },
  },
  opts = {
    output = {
      use_terminal = true,
      preserve_output = false,
    },
    task_list = {
      direction = "bottom",
      min_height = 10,
      max_height = 0.35,
    },
  },
}
