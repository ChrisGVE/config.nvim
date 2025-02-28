-- lua/plugins/ai-assistant.lua
--
vim.api.nvim_create_user_command("AvanteCreateTest", function()
  vim.cmd([[AvanteAsk Create a unit test file for this module. Format it as a complete file.]])
  -- Then use callback to create the file
end, {})

return {
  -- Avante.nvim - Primary AI assistant with shortcuts
  {
    "yetone/avante.nvim",
    enabled = true,
    event = "VeryLazy",
    keys = {
      { "_a", "", desc = "AI Assistant" },
      {
        "_ad",
        function()
          vim.cmd([[AvanteAsk Generate comprehensive documentation]])
        end,
        desc = "Generate docs",
        mode = { "n", "v" },
      },
      {
        "_ac",
        function()
          vim.cmd([[AvanteAsk Using the write_file tool, create a proper unit test for this code.]])
        end,
        desc = "Create test file",
        mode = { "n", "v" },
      },
      {
        "_at",
        function()
          vim.cmd([[AvanteAsk Generate unit tests]])
        end,
        desc = "Generate tests",
        mode = { "n", "v" },
      },
      {
        "_ar",
        function()
          vim.cmd([[AvanteAsk Refactor this code]])
        end,
        desc = "Refactor code",
        mode = { "n", "v" },
      },
      {
        "_ao",
        function()
          vim.cmd([[AvanteAsk Optimize this code]])
        end,
        desc = "Optimize code",
        mode = { "n", "v" },
      },
      {
        "_aS",
        function()
          vim.cmd([[AvanteAsk Simplify this code]])
        end,
        desc = "Simplify code",
        mode = { "n", "v" },
      },
    },
    opts = {
      provider = "claude",
      claude = {
        model = "claude-3-5-sonnet-20241022",
      },
      openai = {
        model = "gpt-4o",
      },
      behaviour = {
        enable_cursor_planning_mode = true,
        auto_apply_diff_after_generation = true, -- Auto-apply diffs
      },
      mappings = {
        ask = "_aa",
        edit = "_ae",
        refresh = "_aR",
        focus = "_af",
        toggle = {
          default = "_at",
          debug = "_aD",
          hint = "_ah",
          suggestion = "_as",
          repomap = "_am",
        },
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
  },

  -- Blink.cmp with Ollama integration
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    config = function()
      -- Create our Ollama source module
      local ollama_source = {}

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

      function ollama_source.new()
        return ollama_source
      end

      package.loaded["ollama_source"] = ollama_source

      -- Configure blink.cmp with the Ollama source
      require("blink.cmp").setup({
        appearance = {
          nerd_font_variant = "mono",
        },
        completion = {
          ghost_text = {
            enabled = true,
          },
          menu = {
            draw = {
              columns = {
                { "kind_icon", "kind", gap = 1 },
                { "label" },
                { "source_name", gap = 2 }, -- Show source explicitly
              },
            },
          },
        },
        sources = {
          providers = {
            lsp = {
              score_offset = 100, -- Higher priority
            },
            ollama = {
              module = "ollama_source",
              name = "Ollama 🤖", -- Custom icon/name
              score_offset = 90,
            },
          },
          default = {
            "lsp",
            "path",
            "buffer",
            "ollama",
          },
        },
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
}
