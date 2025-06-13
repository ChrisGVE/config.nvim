-----------------------------------------------------------
-- Security keys
-----------------------------------------------------------

local function set_keyring()
  local db = require("databox")
  local safebox = "ai-plugins"
  local apis = {}
  local err
  local success
  local exist = false

  -- initialize the vault
  if db.exists(safebox) then
    apis, err = db.get(safebox)
    if err then
      vim.notify("Error getting the APIs: " .. err, vim.log.levels.ERROR)
    else
      exist = true
    end
  end

  -- Helper function to retrieve secrets from 1Password with improved error handling
  local function fetch_api(vault, api)
    -- Return cached value if available
    if apis[api] then
      return
    end

    -- Command to retrieve secret from 1Password
    local cmd = string.format("op read 'op://%s/%s/credential' --no-newline 2>/dev/null", vault, api)

    -- Execute command with pcall for error handling
    local ok, handle = pcall(io.popen, cmd)
    if not ok then
      vim.notify("Error executing 1Password command: " .. tostring(handle), vim.log.levels.ERROR)
      return
    end

    if handle then
      local result = handle:read("*a")
      local close_ok, close_err = handle:close()

      if not close_ok then
        vim.notify("Error closing handle: " .. tostring(close_err), vim.log.levels.WARN)
        return
      end
      if result and #result > 0 then
        -- Cache the result
        apis[api] = vim.trim(result)
        -- Save to persistent cache
        if exist then
          success, err = db.update(safebox, apis)
          if not success then
            vim.notify("Error updating the vault: " .. err, vim.log.levels.ERROR)
            return
          end
        else
          success, err = db.set(safebox, apis)
          if not success then
            vim.notify("Error creating the vault: " .. err, vim.log.levels.ERROR)
            return
          end
          exist = true
        end
      end
      return true
    end

    vim.notify("Failed to retrieve secret from 1Password: " .. api, vim.log.levels.WARN)
  end

  local function set_env(api, vault)
    success = fetch_api(api, vault)
    if success and apis and apis[api] then
      vim.env[api] = apis[api]
    end
  end

  set_env("API", "OPENROUTER_API_KEY")
  set_env("API", "DEEPSEEK_API_KEY")
  set_env("API", "OPENAI_API_KEY")
  set_env("API", "QDRANT_API_KEY")
  set_env("API", "GOOGLE_API_KEY")
  set_env("API", "MEM0_API_KEY")
  set_env("API", "BRAVE_API_KEY")
  set_env("API", "GROQ_API_KEY")
  set_env("API", "ANTHROPIC_API_KEY")
  set_env("API", "TAVILY_API_KEY")
end

-----------------------------------------------------------
-- Avante configuration
-----------------------------------------------------------

-- Views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3

return {
  {
    "yetone/avante.nvim",
    config = function()
      set_keyring()
      require("avante").setup({
        provider = "ollama",
        providers = {
          ollama = {
            model = "qwen3:30b-a3b-no_think",
            endpoint = "http://localhost:11434",
          },
          openrouter = {
            __inherited_from = "openai",
            endpoint = "https://openrouter.ai/api/v1",
            api_key_name = "OPENROUTER_API_KEY",
            model = "deepseek/deepseek-r1",
          },
          deepseek_r1 = {
            __inherited_from = "openai",
            api_key_name = "DEEPSEEK_API_KEY",
            endpoint = "https://api.deepseek.com",
            model = "deepseek-r1",
          },
        },
        rag_service = {
          enabled = false,
          host_mount = os.getenv("HOME") .. "/dev",
          provider = "ollama",
          llm_model = "",
          embed_model = "",
          endpoint = "http://localhost:11434",
        },
        web_search_engine = {
          provider = "tavily",
        },
      })
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "chrisgve/databox.nvim",
    },
    event = "VeryLazy",
    version = false,
    build = "make",
  },
}
