local function is_openai_available()
  return os.getenv("OPENAI_API_KEY")
end

local function is_claude_available()
  return os.getenv("ANTHORPIC_API_KEY")
end

local function is_deepseek_available()
  return os.getenv("DEEPSEEK_API_KEY")
end

local function is_groq_available()
  return os.getenv("GROQ_API_KEY")
end

local function is_tavily_available()
  return os.getenv("TAVILY_API_KEY")
end

local function is_ollama_available()
  return os.execute("curl -s http://localhost:11434/api/tags > /dev/null 2>&1") == 0
end

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      strategies = {
        chat = {
          tools = {
            ["mcp"] = {
              -- calling it in a function would prevent mcphub from being loaded before it's needed
              callback = function()
                return require("mcphub.extensions.codecompanion")
              end,
              description = "Call tools and resources from the MCP Servers",
            },
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
    },
    -- uncomment the following line to load hub lazily
    --cmd = "MCPHub",  -- lazy load
    build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
    -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
    -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
    opts = {
      auto_approve = true,
      extensions = {
        codecompanion = {
          -- Show the mcp tool result in the chat buffer
          show_result_in_chat = true,
          make_vars = true, -- make chat #variables from MCP server resources
          make_slash_commands = true, -- make /slash_commands from MCP server prompts
        },
      },
    },
  },
}
