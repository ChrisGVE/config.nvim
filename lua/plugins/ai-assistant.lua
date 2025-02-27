-- AI Assistant Integration for Neovim
-- This configuration integrates:
--  - avante.nvim for advanced AI coding assistance
--  - minuet-ai.nvim for intelligent code completion
--  - blink.cmp with custom Ollama local model integration
--  - Optimized model selection based on task requirements

-- Create our custom module for Ollama integration
local M = {}

-- Define the Ollama integration for blink.cmp
M.setup_ollama_source = function()
  local ollama_source = {}

  -- Implementation of the completion function for Ollama
  function ollama_source:complete(params, callback)
    local Job = require("plenary.job")
    local context = params.context or {}
    local prefix = context.prefix or ""

    -- Skip if prefix is too short
    if #prefix < 2 then
      callback({})
      return
    end

    -- Current buffer type for model context
    local ft = vim.bo.filetype
    local model = "mistral:latest" -- Default model

    -- Select appropriate model based on filetype
    if ft == "lua" or ft == "python" or ft == "c" or ft == "cpp" or ft == "zig" then
      model = "codellama:7b-instruct" -- Better for code
    end

    -- Prepare the payload for Ollama API
    local payload = {
      model = model,
      prompt = prefix,
      stream = false,
      options = {
        temperature = 0.2,
        top_k = 50,
        top_p = 0.9,
        num_predict = 30,
      },
    }

    local json_payload = vim.fn.json_encode(payload)

    -- Make HTTP request to local Ollama server
    Job:new({
      command = "curl",
      args = {
        "-s",
        "-X",
        "POST",
        "-H",
        "Content-Type: application/json",
        "-d",
        json_payload,
        "http://localhost:11434/api/generate",
      },
      on_exit = function(j, _)
        local result = table.concat(j:result(), "\n")
        local ok, parsed = pcall(vim.fn.json_decode, result)

        if not ok or not parsed or not parsed.response then
          callback({})
          return
        end

        -- Create completion item
        local completion = {
          label = parsed.response,
          insertText = parsed.response,
          kind = require("blink.cmp.types").CompletionItemKind.Text,
          labelDetails = {
            description = "(Ollama)",
          },
        }

        callback({ completion })
      end,
    }):start()
  end

  -- Constructor for the source
  function ollama_source.new()
    return ollama_source
  end

  -- Register the source with Lua's package system
  package.loaded["ollama_source"] = ollama_source
end

-- Main plugin configuration
return {
  -- Avante.nvim - Primary AI assistant
  {
    "yetone/avante.nvim",
    enabled = true,
    event = "VeryLazy",
    lazy = false,
    version = false,
    keys = {
      { "_a", "", desc = "AI Assistant" },
    },
    opts = {
      mappings = {
        ask = "_aa",
        edit = "_ae",
        refresh = "_ar",
        focus = "_af",
        toggle = {
          default = "_at",
          debug = "_ad",
          hint = "_ah",
          suggestion = "_as",
          repomap = "_aR",
        },
        diff = {
          next = "]c",
          prev = "[c",
        },
        files = {
          add_current = "_.",
        },
      },
      behaviour = {
        auto_suggestions = false,
      },
      -- Configure multiple providers for different use cases
      provider = "claude",
      openai = {
        model = "gpt-4o",
        api_key = function()
          return os.getenv("OPENAI_API_KEY")
        end,
      },
      claude = {
        model = "claude-3-5-sonnet-20241022",
        api_key = function()
          return os.getenv("ANTHROPIC_API_KEY")
        end,
      },
      auto_suggestions_provider = "claude",
      dual_boost = {
        enabled = true,
      },
      file_selector = {
        provider = "snacks",
      },
    },
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
    config = function(_, opts)
      -- Setup task-specific commands
      local avante = require("avante")

      -- Register specialized commands before main setup
      avante.register_command("doc", {
        description = "Generate documentation",
        prompt = "Please generate documentation for the following code:\n\n{selection}",
      })

      avante.register_command("test", {
        description = "Generate unit tests",
        prompt = "Please generate comprehensive unit tests for the following code:\n\n{selection}",
      })

      avante.register_command("refactor", {
        description = "Refactor code",
        prompt = "Please refactor the following code for improved readability and performance:\n\n{selection}",
      })

      avante.register_command("optimize", {
        description = "Optimize code",
        prompt = "Please optimize the following code for better performance and efficiency:\n\n{selection}",
      })

      avante.register_command("simplify", {
        description = "Simplify code",
        prompt = "Please simplify the following code and suggest existing libraries or patterns that could replace custom implementations:\n\n{selection}",
      })

      avante.register_command("bootstrap", {
        description = "Bootstrap new project",
        model = "claude-3-7-sonnet-20250212", -- Use most capable model for project setup
        prompt = "Help me bootstrap a new project. Details:\n\n{selection}",
      })

      avante.setup(opts)
    end,
  },

  -- Minuet AI - Code completion enhancement
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "saghen/blink.compat",
      "saghen/blink.cmp",
    },
    config = function()
      require("minuet").setup({
        virtualtext = {
          auto_trigger_ft = { "lua", "python", "c", "cpp", "rust", "zig" },
          keymap = {
            accept = "<A-A>",
            accept_line = "<A-a>",
            accept_n_lines = "<A-z>",
            prev = "<A-[>",
            next = "<A-]>",
            dismiss = "<A-e>",
          },
          show_on_completion_menu = true,
        },
        blink = {
          enable_auto_complete = true,
        },
        provider = "openai", -- Default to OpenAI for code completions (more efficient)
      })
    end,
  },

  -- Blink CMP - Code completion with Ollama integration
  {
    "saghen/blink.cmp",
    dependencies = {
      {
        "saghen/blink.compat",
        optional = false,
        lazy = true,
        opts = {
          impersonate_nvim_cmp = true,
        },
      },
      "milanglacier/minuet-ai.nvim",
      "Kaiser-Yang/blink-cmp-dictionary",
      "Kaiser-Yang/blink-cmp-git",
    },
    lazy = true,
    event = "InsertEnter",
    opts = {
      sources = {
        default = {
          "lsp",
          "path",
          "buffer",
          "minuet",
          "ollama", -- Our custom Ollama source
          "avante_mentions",
          "avante_files",
          "avante_commands",
        },
        providers = {
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",
            enabled = true,
            fallbacks = { "minuet" },
          },
          minuet = {
            module = "minuet.blink",
            name = "Minuet",
            score_offset = 100,
          },
          ollama = {
            module = "ollama_source",
            name = "Ollama",
            score_offset = 50,
          },
          avante_commands = {
            name = "avante_commands",
            module = "blink.compat.source",
            score_offset = 90,
            opts = {},
          },
          avante_files = {
            name = "avante_files",
            module = "blink.compat.source",
            score_offset = 100,
            opts = {},
          },
          avante_mentions = {
            name = "avante_mentions",
            module = "blink.compat.source",
            score_offset = 1000,
            opts = {},
          },
        },
      },
      completion = {
        throttle_ms = 100,
        ghost_text = {
          enabled = true,
          show_with_selection = true,
          show_without_selection = true,
        },
      },
    },
    config = function(_, opts)
      -- Setup Ollama integration
      M.setup_ollama_source()

      -- Configure blink.cmp
      require("blink.cmp").setup(opts)
    end,
  },

  -- Disable any conflicting plugins
  { "jackMort/ChatGPT.nvim", enabled = false },
  { "olimorris/codecompanion.nvim", enabled = false },
}
