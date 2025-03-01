-- Create our Ollama source module
local ollama_source = {}

function ollama_source:complete(params, callback)
  local Job = require("plenary.job")
  local context = params.context or {}
  local prefix = context.prefix or ""

  -- Current buffer type for model context
  local ft = vim.bo.filetype
  local model = "mistral:latest" -- Default model

  -- Select appropriate model based on filetype
  if ft == "lua" or ft == "python" or ft == "c" or ft == "cpp" or ft == "zig" then
    model = "codellama:7b-instruct" -- Better for code
  end

  -- Skip if prefix is too short
  if #prefix < 2 then
    callback({})
    return
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

return {
  -- Blink.cmp with Ollama integration
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    opts = {
      snippets = {
        expand = function(snippet, _)
          return LazyVim.cmp.expand(snippet)
        end,
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          draw = {
            treesitter = { "lsp" },
            columns = {
              { "kind_icon", "kind", gap = 1 },
              { "label" },
              { "source_name", gap = 2 }, -- Show source explicitly
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = {
          enabled = vim.g.ai_cmp, -- true?
        },
      },
      sources = {
        providers = {
          lsp = {
            score_offset = 90, -- Higher priority
          },
          ollama = {
            module = "ollama_source",
            name = "Ollama 🤖", -- Custom icon/name
            score_offset = 100,
          },
        },
        default = {
          "lsp",
          "path",
          "snippets",
          "buffer",
          "ollama",
        },
      },
      cmdline = {
        enabled = false,
      },

      keymap = {
        preset = "enter",
        ["C-y"] = { "select_and_accept" },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
}
