local python_filetypes = { "python" }

local function update_remote_plugins_if_ready()
  local host_prog = vim.g.python3_host_prog
  if not host_prog or host_prog == "" then
    return
  end

  if vim.fn.executable(host_prog) ~= 1 then
    return
  end

  vim.cmd("silent! UpdateRemotePlugins")
end

local function run_task(task_def)
  local ok, overseer = pcall(require, "overseer")
  if not ok then
    vim.notify("overseer.nvim is required for this action", vim.log.levels.WARN)
    return
  end

  local task = overseer.new_task(task_def)
  task:start()
  overseer.open({ enter = false })
end

local function choose_manager(callback)
  vim.ui.select({ "uv", "conda", "mamba", "pyenv" }, {
    prompt = "Select Python environment manager",
  }, callback)
end

local function prompt_create_environment()
  choose_manager(function(manager)
    if not manager then
      return
    end

    if vim.fn.executable(manager) ~= 1 then
      vim.notify(("`%s` is not available in PATH"):format(manager), vim.log.levels.WARN)
      return
    end

    if manager == "uv" then
      vim.ui.input({ prompt = "uv venv path [.venv]: " }, function(path)
        local env_path = (path and path ~= "") and path or ".venv"
        run_task({
          name = "python: uv venv " .. env_path,
          cmd = "uv",
          args = { "venv", env_path },
          cwd = vim.fn.getcwd(),
          components = { "default", "on_output_quickfix" },
        })
      end)
      return
    end

    if manager == "pyenv" then
      vim.ui.input({ prompt = "pyenv Python version (e.g. 3.12.2): " }, function(version)
        if not version or version == "" then
          return
        end
        vim.ui.input({ prompt = "pyenv environment name: " }, function(env_name)
          if not env_name or env_name == "" then
            return
          end
          run_task({
            name = ("python: pyenv virtualenv %s %s"):format(version, env_name),
            cmd = "pyenv",
            args = { "virtualenv", version, env_name },
            cwd = vim.fn.getcwd(),
            components = { "default", "on_output_quickfix" },
          })
        end)
      end)
      return
    end

    vim.ui.input({ prompt = manager .. " env name: " }, function(env_name)
      if not env_name or env_name == "" then
        return
      end
      vim.ui.input({ prompt = manager .. " python version [3.12]: " }, function(version)
        local python_version = (version and version ~= "") and version or "3.12"
        run_task({
          name = ("python: %s create -n %s python=%s"):format(manager, env_name, python_version),
          cmd = manager,
          args = { "create", "-y", "-n", env_name, "python=" .. python_version },
          cwd = vim.fn.getcwd(),
          components = { "default", "on_output_quickfix" },
        })
      end)
    end)
  end)
end

local function prompt_update_environment()
  choose_manager(function(manager)
    if not manager then
      return
    end

    if vim.fn.executable(manager) ~= 1 then
      vim.notify(("`%s` is not available in PATH"):format(manager), vim.log.levels.WARN)
      return
    end

    if manager == "uv" then
      run_task({
        name = "python: uv sync --upgrade",
        cmd = "uv",
        args = { "sync", "--upgrade" },
        cwd = vim.fn.getcwd(),
        components = { "default", "on_output_quickfix" },
      })
      return
    end

    if manager == "pyenv" then
      vim.notify("pyenv does not provide a single 'update all packages' workflow.", vim.log.levels.INFO)
      vim.notify("Use a selected environment + pip/uv/pdm to manage packages.", vim.log.levels.INFO)
      return
    end

    vim.ui.input({ prompt = manager .. " env name (blank = current active): " }, function(env_name)
      local args = { "update", "--all", "-y" }
      if env_name and env_name ~= "" then
        args = { "update", "--all", "-y", "-n", env_name }
      end
      run_task({
        name = ("python: %s update --all"):format(manager),
        cmd = manager,
        args = args,
        cwd = vim.fn.getcwd(),
        components = { "default", "on_output_quickfix" },
      })
    end)
  end)
end

return {
  {
    "linux-cultist/venv-selector.nvim",
    branch = "main",
    ft = python_filetypes,
    cmd = { "VenvSelect", "VenvSelectLog", "VenvSelectCached" },
    keys = {
      { "<localleader>v", "", ft = python_filetypes, desc = "Python Environments" },
      { "<localleader>vs", "<cmd>VenvSelect<cr>", ft = python_filetypes, desc = "Select Environment" },
      { "<localleader>vL", "<cmd>VenvSelectLog<cr>", ft = python_filetypes, desc = "Environment Log" },
      {
        "<localleader>vc",
        function()
          prompt_create_environment()
        end,
        ft = python_filetypes,
        desc = "Create Environment",
      },
      {
        "<localleader>vu",
        function()
          prompt_update_environment()
        end,
        ft = python_filetypes,
        desc = "Update Environment Packages",
      },
    },
    opts = {
      options = {
        picker = "snacks",
        notify_user_on_venv_activation = true,
      },
    },
  },
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style = "hydrogen",
      output_extension = "auto",
      force_ft = nil,
      custom_language_formatting = {
        python = {
          extension = "py",
          style = "hydrogen",
          force_ft = "python",
        },
      },
    },
  },
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = update_remote_plugins_if_ready,
    cmd = {
      "MoltenInit",
      "MoltenDeinit",
      "MoltenEvaluateLine",
      "MoltenEvaluateVisual",
      "MoltenEvaluateOperator",
      "MoltenReevaluateCell",
      "MoltenHideOutput",
      "MoltenEnterOutput",
      "MoltenDelete",
    },
    init = function()
      vim.g.molten_image_provider = "none"
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
    end,
    keys = {
      { "<localleader>m", "", ft = python_filetypes, desc = "Molten" },
      { "<localleader>mi", "<cmd>MoltenInit<cr>", ft = python_filetypes, desc = "Init Kernel" },
      { "<localleader>ml", "<cmd>MoltenEvaluateLine<cr>", ft = python_filetypes, desc = "Evaluate Line" },
      { "<localleader>mr", "<cmd>MoltenReevaluateCell<cr>", ft = python_filetypes, desc = "Reevaluate Cell" },
      { "<localleader>md", "<cmd>MoltenDelete<cr>", ft = python_filetypes, desc = "Delete Cell" },
      { "<localleader>mh", "<cmd>MoltenHideOutput<cr>", ft = python_filetypes, desc = "Hide Output" },
      { "<localleader>mo", "<cmd>noautocmd MoltenEnterOutput<cr>", ft = python_filetypes, desc = "Enter Output" },
      {
        "<localleader>mv",
        ":<C-u>MoltenEvaluateVisual<cr>gv",
        mode = "v",
        ft = python_filetypes,
        desc = "Evaluate Visual Selection",
      },
      {
        "<localleader>me",
        "<cmd>MoltenEvaluateOperator<cr>",
        ft = python_filetypes,
        desc = "Evaluate Operator",
      },
    },
  },
}
