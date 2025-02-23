-- local map = vim.keymap.set
--
-- map("n", "_ad", function()
--   require("codecompanion").prompt("docs")
-- end, { desc = "Write documentation", noremap = true, silent = true })

-- check if lua/plugins/codecompanion/fidget-spinner.lua exists, if not create it

return {
  "olimorris/codecompanion.nvim",
  enabled = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "j-hui/fidget.nvim",
    {
      "saghen/blink.cmp",
      opts = {
        sources = {
          default = { "codecompanion" },
        },
      },
    },
  },
  keys = {
    { "_a", "", desc = "Code companion" },
    { "_aa", "<cmd>CodeCompanionActions<cr>", desc = "Actions" },
    { "_at", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" },
    { "_ae", "<cmd>CodeCompanion /explain<cr>", desc = "Explain", mode = { "n", "v" } },
    { "_af", "<cmd>CodeCompanion /fix code<cr>", desc = "Fix code", mode = { "n", "v" } },
    { "_au", "<cmd>CodeCompanion /unit tests<cr>", desc = "Unit tests", mode = { "n", "v" } },
    { "_ag", "<cmd>CodeCompanion /generate a commit message<cr>", desc = "Generate Commit", mode = { "n", "v" } },
    {
      "_ad",
      "<cmd>CodeCompanion /explain lsp diagnostics<cr>",
      desc = "Explain LSP diagnostics",
      mode = { "n", "v" },
    },
  },
  opts = {
    adapters = {
      anthropic = function()
        return require("codecompanion.adapters").extend("anthropic", {
          env = {
            api_key = function()
              return os.getenv("ANTHROPIC_API_KEY")
            end,
          },
          schema = {
            model = {
              default = "claude-3-5-sonnet-20241022",
            },
          },
        })
      end,
      openai = function()
        return require("codecompanion.adapters").extend("openai", {
          env = {
            api_key = function()
              return os.getenv("OPENAI_API_KEY")
            end,
          },
          schema = {
            model = {
              default = "gpt-4",
            },
          },
        })
      end,
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "llama3", -- Give this adapter a different name to differentiate it from the default ollama adapter
          schema = {
            model = {
              default = "llama3:latest",
            },
            num_ctx = {
              default = 16384,
            },
            num_predict = {
              default = -1,
            },
            -- temperature = {
            --   order = 2,
            --   mapping = "parameters",
            --   type = "number",
            --   optional = true,
            --   default = 0.8,
            --   desc = "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.",
            --   validate = function(n)
            --     return n >= 0 and n <= 2, "Must be between 0 and 2"
            --   end,
            -- },
            -- max_completion_tokens = {
            --   order = 3,
            --   mapping = "parameters",
            --   type = "integer",
            --   optional = true,
            --   default = nil,
            --   desc = "An upper bound for the number of tokens that can be generated for a completion.",
            --   validate = function(n)
            --     return n > 0, "Must be greater than 0"
            --   end,
            -- },
            -- stop = {
            --   order = 4,
            --   mapping = "parameters",
            --   type = "string",
            --   optional = true,
            --   default = nil,
            --   desc = "Sets the stop sequences to use. When this pattern is encountered the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate stop parameters in a modelfile.",
            --   validate = function(s)
            --     return s:len() > 0, "Cannot be an empty string"
            --   end,
            -- },
            -- logit_bias = {
            --   order = 5,
            --   mapping = "parameters",
            --   type = "map",
            --   optional = true,
            --   default = nil,
            --   desc = "Modify the likelihood of specified tokens appearing in the completion. Maps tokens (specified by their token ID) to an associated bias value from -100 to 100. Use https://platform.openai.com/tokenizer to find token IDs.",
            --   subtype_key = {
            --     type = "integer",
            --   },
            --   subtype = {
            --     type = "integer",
            --     validate = function(n)
            --       return n >= -100 and n <= 100, "Must be between -100 and 100"
            --     end,
            --   },
            -- },
          },
        })
      end,
      ollama_remote = function()
        return require("codecompanion.adapters").extend("ollama", {
          env = {
            url = "https://my_ollama_url",
            api_key = "OLLAMA_API_KEY",
          },
          headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer ${api_key}",
          },
          parameters = {
            sync = true,
          },
        })
      end,
    },
    strategies = {
      -- Change the default adapter
      chat = {
        adapter = "anthropic",
        keymaps = {
          send = {
            modes = { n = "<C-s>", i = "<C-s>" },
            description = "Send messages",
          },
          close = {
            modes = { n = "<C-c>", i = "<C-c>" },
            description = "Close chat",
          },
        },
        slash_commands = {
          ["file"] = {
            -- Location to the slash command in CodeCompanion
            callback = "strategies.chat.slash_commands.file",
            description = "Select a file using Telescope",
            opts = {
              provider = "snacks", -- Other options include 'default', 'mini_pick', 'fzf_lua', snacks
              contains_code = true,
            },
            ["mycmd"] = {
              description = "My fancy new command",
              ---@param chat CodeCompanion.Chat
              callback = function(chat)
                return chat:add_buf_message({ content = "Just writing to the chat buffer" })
              end,
            },
          },
        },
        agents = {
          ["my_agent"] = {
            description = "A custom agent combining tools",
            system_prompt = "Describe what the agent should do",
            tools = {
              "cmd_runner",
              "editor",
              -- Add your own tools or reuse existing ones
            },
          },
        },
        tools = {
          ["my_tool"] = {
            description = "Run a custom task",
            callback = function(command)
              -- Perform the custom task here
              return "Tool result"
            end,
          },
        },
        variables = {
          ["my_var"] = {
            callback = function()
              return "Your custom content here."
            end,
            description = "Explain what my_var does",
            opts = {
              contains_code = false,
            },
          },
        },

        -- Change the default icons
        icons = {
          pinned_buffer = " ",
          watched_buffer = "👀 ",
        },

        -- Alter the sizing of the debug window
        debug_window = {
          ---@return number|fun(): number
          width = vim.o.columns - 5,
          ---@return number|fun(): number
          height = vim.o.lines - 2,
        },

        -- Options to customize the UI of the chat buffer
        window = {
          layout = "vertical", -- float|vertical|horizontal|buffer
          position = nil, -- left|right|top|bottom (nil will default depending on vim.opt.plitright|vim.opt.splitbelow)
          border = "single",
          height = 0.8,
          width = 0.45,
          relative = "editor",
          opts = {
            breakindent = true,
            cursorcolumn = false,
            cursorline = false,
            foldcolumn = "0",
            linebreak = true,
            list = false,
            numberwidth = 1,
            signcolumn = "no",
            spell = false,
            wrap = true,
          },
        },

        ---Customize how tokens are displayed
        ---@param tokens number
        ---@param adapter CodeCompanion.Adapter
        ---@return string
        token_count = function(tokens, adapter)
          return " (" .. tokens .. " tokens)"
        end,
        roles = {
          ---The header name for the LLM's messages
          ---@type string|fun(adapter: CodeCompanion.Adapter): string
          llm = function(adapter)
            return "CodeCompanion (" .. adapter.formatted_name .. ")"
          end,

          ---The header name for your messages
          ---@type string
          user = "Me",
        },
      },
      inline = {
        adapter = "openai",
        keymaps = {
          accept_change = {
            modes = { n = "<localleader>a" },
            description = "Accept the suggested change",
          },
          reject_change = {
            modes = { n = "<localleader>r" },
            description = "Reject the suggested change",
          },
        },
      },
    },
    display = {
      action_palette = {
        width = 95,
        height = 10,
        prompt = "Prompt ", -- Prompt used for interactive LLM calls
        provider = "default", -- default|telescope|mini_pick
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
        show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
        separator = "─", -- The separator between the different messages in the chat buffer
        show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
        show_settings = true, -- Show LLM settings at the top of the chat buffer?
        show_token_count = true, -- Show the token count for each response?
        start_in_insert_mode = false, -- Open the chat buffer in insert mode?
      },
      inline = {
        layout = "vertical", -- vertical|horizontal|buffer
      },
    },
    prompt_library = {
      ["Docusaurus"] = {
        strategy = "chat",
        description = "Write documentation for me",
        opts = {
          index = 11,
          is_slash_cmd = true,
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
    opts = {
      language = "English",
      -- Set debug logging
      log_level = "DEBUG",
      -- Customize the system prompt
      -- system_prompt = function(opts)
      --   return "My new system prompt"
      -- end,
    },
    -- init = function()
    --   require("plugins.codecompanion.figet-spinner"):init()
    -- end,
  },
}
