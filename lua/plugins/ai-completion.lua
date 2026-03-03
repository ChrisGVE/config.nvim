return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      provider = "openai_compatible",
      provider_options = {
        openai_compatible = {
          model = "gpt-4.1-nano",
          end_point = "https://routellm.abacus.ai/v1/chat/completions",
          api_key = "ABACUS_API_KEY",
          name = "Abacus",
          stream = true,
          optional = {
            max_tokens = 256,
          },
        },
      },
    },
  },

  {
    "saghen/blink.cmp",
    dependencies = { "milanglacier/minuet-ai.nvim" },
    opts_extend = { "sources.default" },
    opts = {
      keymap = {
        ["<A-y>"] = {
          function()
            return require("minuet").make_blink_map()
          end,
        },
      },
      sources = {
        default = { "minuet" },
        providers = {
          minuet = {
            name = "minuet",
            module = "minuet.blink",
            async = true,
            timeout_ms = 3000,
            score_offset = 50,
          },
        },
      },
      completion = {
        trigger = {
          prefetch_on_insert = false,
        },
      },
    },
  },
}
