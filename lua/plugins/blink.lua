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
          avante = {
            module = "blink-cmp-avante",
            name = "Avante",
            score_offset = 85,
          },
          lsp = {
            score_offset = 90, -- Higher priority
          },
          path = {
            score_offset = 100,
          },
          buffer = {
            score_offset = 100,
          },
          snippets = {
            score_offset = 95,
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 96,
          },
        },
        default = {
          "lazydev",
          "avante",
          "lsp",
          "path",
          "snippets",
          "buffer",
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
      {
        "Kaiser-Yang/blink-cmp-avante",
        -- opts = {
        --   kind_icons = {
        --     AvanteCmd = "",
        --     AvanteMention = "",
        --   },
        --   avante = {
        --     command = {
        --       get_kind_name = function(_)
        --         return "AvanteCmd"
        --       end,
        --     },
        --     mention = {
        --       get_kind_name = function(_)
        --         return "AvanteMention"
        --       end,
        --     },
        --   },
        -- },
      },
    },
  },
}
