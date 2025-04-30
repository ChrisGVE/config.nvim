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

-- Configuring the System Prompt
--
-- Standard prompt
--
-- You are an AI programming assistant named "CodeCompanion". You are currently plugged in to the Neovim text editor on a user's machine.
--
-- Your core tasks include:
-- - Answering general programming questions.
-- - Explaining how the code in a Neovim buffer works.
-- - Reviewing the selected code in a Neovim buffer.
-- - Generating unit tests for the selected code.
-- - Proposing fixes for problems in the selected code.
-- - Scaffolding code for a new workspace.
-- - Finding relevant code to the user's query.
-- - Proposing fixes for test failures.
-- - Answering questions about Neovim.
-- - Running tools.
--
-- You must:
-- - Follow the user's requirements carefully and to the letter.
-- - Keep your answers short and impersonal, especially if the user responds with context outside of your tasks.
-- - Minimize other prose.
-- - Use Markdown formatting in your answers.
-- - Include the programming language name at the start of the Markdown code blocks.
-- - Avoid including line numbers in code blocks.
-- - Avoid wrapping the whole response in triple backticks.
-- - Only return code that's relevant to the task at hand. You may not need to return all of the code that the user has shared.
-- - Use actual line breaks instead of '\n' in your response to begin new lines.
-- - Use '\n' only when you want a literal backslash followed by a character 'n'.
-- - All non-code responses must be in %s.
--
-- When given a task:
-- 1. Think step-by-step and describe your plan for what to build in pseudocode, written out in great detail, unless asked not to do so.
-- 2. Output the code in a single code block, being careful to only return relevant code.
-- 3. You should always generate short suggestions for the next user turns that are relevant to the conversation.
-- 4. You can only give one reply for each conversation turn.
--
-- require("codecompanion").setup({
--   opts = {
--     system_prompt = function(opts)
--       return "My new system prompt"
--     end,
--   },
-- }),

-- vim.keymap.set("n", "<LocalLeader>d", function()
--   require("codecompanion").prompt("docs")
-- end, { noremap = true, silent = true })

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      prompt_library = {
        ["Docusaurus"] = {
          strategy = "chat",
          description = "Write documentation for me",
          opts = {
            index = 11,
            is_slash_cmd = false,
            auto_submit = false,
            short_name = "docs",
          },
          references = {
            {
              type = "file",
              path = {
                "doc/.vitepress/config.mjs",
                "lua/codecompanion/config.lua",
                "README.md",
              },
            },
          },
          prompts = {
            {
              role = "user",
              content = [[I'm rewriting the documentation for my plugin CodeCompanion.nvim, as I'm moving to a vitepress website. Can you help me rewrite it?

I'm sharing my vitepress config file so you have the context of how the documentation website is structured in the `sidebar` section of that file.

I'm also sharing my `config.lua` file which I'm mapping to the `configuration` section of the sidebar.
]],
            },
          },
        },
      },
      display = {
        action_palette = {
          width = 95,
          height = 10,
          prompt = "Prompt ", -- Prompt used for interactive LLM call
          provider = "default", -- Can be "default", "telescope", or "mini_pick". If not specified, the plugin will autodetect installed providers.
          opts = {
            show_default_actions = true, -- Show the default actions in the action palette?
            show_default_prompt_library = true, -- Show the default prompt library in the action palette?
          },
        },
        diff = {
          enabled = true,
          close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
          layout = "vertical", -- vertical|horizontal split for default provider
          opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
          provider = "mini_diff", -- default|mini_diff
        },
        chat = {
          intro_message = "Welcome to CodeCompanion ✨! Press ? for options",
          show_header_separator = true, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
          separator = "─", -- The separator between the different messages in the chat buffer
          show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
          show_settings = true, -- Show LLM settings at the top of the chat buffer?
          show_token_count = true, -- Show the token count for each response?
          start_in_insert_mode = false, -- Open the chat buffer in insert mode?
        },
        inline = {
          layhout = "vertical", -- vertical|horizontal|buffer
        },
      },
      adapters = {
        antrhopic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            schema = {
              model = {
                default = "claude-3-5-haiku-20241022",
                choices = {
                  "claude-3-5-haiku-20241022",
                  "claude-3-5-sonnet-20241022",
                  ["claude-3-7-sonnet-20250219"] = { opts = { can_reason = true } },
                },
              },
            },
            env = {
              api_key = "cmd:op read op://personal/Anthropic/credential --no-newline",
            },
          })
        end,
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            schema = {
              model = {
                default = "gpt-3.5-turbo",
                choices = {
                  "gpt-3.5-turbo",
                  "gpt-4o",
                  "gpt-4o-mini",
                },
              },
            },
            env = {
              api_key = "cmd:op read op://personal/OpenAI/credential --no-newline",
            },
          })
        end,
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            schema = {
              model = {
                default = "gemini-2.0-flash",
                choices = {
                  "gemini-2.0-flash",
                  ["gemini-3.pro-preview-03-25"] = { opts = { can_reason = true } },
                },
              },
            },
            env = {
              api_key = "cmd:op read op://personal/Gemini/credential --no-newline",
            },
          })
        end,
        deepseek = function()
          return require("codecompanion.adapters").extend("deepseek", {
            schema = {
              model = {
                default = "deepseek-chat",
              },
            },
            env = {
              api_key = "cmd:op read op://personal/Deepseek/credential --no-newline",
            },
          })
        end,
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "ollama",
          })
        end,
        qwen2_05b = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "qwen2_05b", -- Give this adapter a different name to differentiate it from the default adapter
            schema = {
              model = {
                default = "qwen2:0.5b",
              },
              num_ctx = {
                default = 16384,
              },
              num_predict = {
                default = -1,
              },
            },
          })
        end,
      },
      strategies = {
        inline = {
          adapter = "gemini",
          inline = {
            keymaps = {
              accept_change = {
                modes = { n = "ga" },
                description = "Accept the suggested change",
              },
              reject_change = {
                modes = { n = "gr" },
                description = "Reject the suggested change",
              },
            },
          },
        },
        cmd = {
          adapter = "openai",
        },
        chat = {
          adapter = "gemini",
          tools = {},
          slash_commands = {
            ["file"] = {
              -- Location to the slash command in CodeCompanion
              callback = "strategies.chat.slash_commmans.file",
              description = "Select a file using",
              opts = {
                provider = "snacks",
                contains_code = true,
              },
            },
            ["git_files"] = {
              description = "List git files",
              ---@param chat CodeCompanion.Chat
              callback = function(chat)
                local handle = io.popen("git ls-files")
                if handle ~= nil then
                  local result = handle:read("*a")
                  handle:close()
                  chat:add_reference({ role = "user", content = result }, "git", "<git_files>")
                else
                  return vim.notify("No git files available", vim.log.levels.INFO, { title = "CodeCompanion" })
                end
              end,
              opts = {
                contains_code = false,
              },
            },
          },
          keymaps = {
            send = {
              modes = { n = "<C-s>", i = "<C-s>" },
            },
            close = {
              modes = { n = "<C-c>", i = "<C-c>" },
            },
          },
        },
      },
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            show_result_in_chat = true, -- Show the mcp tool result in the chat buffer
            make_vars = true, -- make chat #variables from MCP server resources
            make_slash_commands = true, -- make /slash_commands from MCP server prompts
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
    },
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
    },
    -- uncomment the following line to load hub lazily
    cmd = "MCPHub", -- lazy load
    build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
    -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
    -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
    opts = {
      config = vim.fn.expand("$XDG_CONFIG_HOME/nvim/mcphub/servers.json"),
      auto_approve = true,
      auto_toggle_mcp_servers = true,
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
