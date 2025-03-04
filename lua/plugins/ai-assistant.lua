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

local function is_avante_available()
  local has_api_key = is_openai_available() or is_claude_available() or is_deepseek_available() or is_groq_available()
  local ollama_running = is_ollama_available()
  return has_api_key or ollama_running
end

return {
  {
    "yetone/avante.nvim",
    enabled = is_avante_available(),
    event = "VeryLazy",
    keys = {
      { "_a", "", desc = "AI Assistant" },
      { "_c", "", desc = "AI Coding Assistant" },
      {
        "_cd",
        function()
          vim.cmd(
            [[AvanteAsk Generate detailed inline documentation, including function signatures, parameters, and return types.]]
          )
        end,
        desc = "Generate Code Documentation",
        mode = { "n", "v" },
      },
      {
        "_ce",
        function()
          vim.cmd(
            [[AvanteAsk Generate user-friendly documentation with examples and explanations suited for end users.]]
          )
        end,
        desc = "Generate End-User Documentation",
        mode = { "n", "v" },
      },
      {
        "_ct",
        function()
          vim.cmd([[AvanteAsk Generate thorough unit tests with appropriate test cases.]])
        end,
        desc = "Generate Unit Tests",
        mode = { "n", "v" },
      },
      {
        "_cr",
        function()
          vim.cmd(
            [[AvanteAsk Improve code readability, maintainability, and performance by refactoring where necessary.]]
          )
        end,
        desc = "Refactor Code",
        mode = { "n", "v" },
      },
      {
        "_co",
        function()
          vim.cmd([[AvanteAsk Optimize this code for efficiency, reducing computational complexity where possible.]])
        end,
        desc = "Optimize Code",
        mode = { "n", "v" },
      },
      {
        "_cS",
        function()
          vim.cmd([[AvanteAsk Simplify this code while maintaining functionality and readability.]])
        end,
        desc = "Simplify Code",
        mode = { "n", "v" },
      },
      { "_t", "", desc = "AI Text Tools" },
      {
        "_tw",
        function()
          vim.cmd([[AvanteAsk Rewrite this text for improved clarity and readability.]])
        end,
        desc = "Rewrite for Clarity",
        mode = { "n", "v" },
      },
      {
        "_ts",
        function()
          vim.cmd([[AvanteAsk Summarize this text while retaining key information.]])
        end,
        desc = "Summarize Text",
        mode = { "n", "v" },
      },
      {
        "_tp",
        function()
          vim.cmd([[AvanteAsk Proofread this text and correct grammar, spelling, and stylistic errors.]])
        end,
        desc = "Proofread and Correct Grammar",
        mode = { "n", "v" },
      },
      {
        "_tg",
        function()
          vim.cmd(
            [[AvanteAsk Generate a concise and meaningful git commit message based on the current changes. Format it according to conventional commits.]]
          )
        end,
        desc = "Generate Git Commit Message",
        mode = { "n", "v" },
      },
    },
    opts = {
      provider = "claude35",
      cursor_applying_provider = "claude37",
      auto_suggestion_provider = "ollama",
      ---Specify the special dual_boost mode
      ---1. enabled: Whether to enable dual_boost mode. Default to false.
      ---2. first_provider: The first provider to generate response. Default to "openai".
      ---3. second_provider: The second provider to generate response. Default to "claude".
      ---4. prompt: The prompt to generate response based on the two reference outputs.
      ---5. timeout: Timeout in milliseconds. Default to 60000.
      ---How it works:
      --- When dual_boost is enabled, avante will generate two responses from the first_provider and second_provider respectively. Then use the response from the first_provider as provider1_output and the response from the second_provider as provider2_output. Finally, avante will generate a response based on the prompt and the two reference outputs, with the default Provider as normal.
      ---Note: This is an experimental feature and may not work as expected.
      dual_boost = {
        enabled = true,
        first_provider = "openai",
        second_provider = "deepseek",
        prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
        timeout = 60000, -- Timeout in milliseconds
      },
      web_search_engine = {
        provider = "tavily",
      },
      ---Specify the behaviour of avante.nvim
      ---1. auto_focus_sidebar              : Whether to automatically focus the sidebar when opening avante.nvim. Default to true.
      ---2. auto_suggestions = false, -- Whether to enable auto suggestions. Default to false.
      ---3. auto_apply_diff_after_generation: Whether to automatically apply diff after LLM response.
      ---                                     This would simulate similar behaviour to cursor. Default to false.
      ---4. auto_set_keymaps                : Whether to automatically set the keymap for the current line. Default to true.
      ---                                     Note that avante will safely set these keymap. See https://github.com/yetone/avante.nvim/wiki#keymaps-and-api-i-guess for more details.
      ---5. auto_set_highlight_group        : Whether to automatically set the highlight group for the current line. Default to true.
      ---6. jump_result_buffer_on_finish = false, -- Whether to automatically jump to the result buffer after generation
      ---7. support_paste_from_clipboard    : Whether to support pasting image from clipboard. This will be determined automatically based whether img-clip is available or not.
      ---8. minimize_diff                   : Whether to remove unchanged lines when applying a code block
      ---9. enable_token_counting           : Whether to enable token counting. Default to true.
      behaviour = {
        auto_suggestions = true,
        auto_set_highlight_group = true,
        auto_set_keymap = true,
        support_paste_from_clipboard = true,
        enable_cursor_planning_mode = true,
        auto_apply_diff_after_generation = true,
      },
      suggestion = {
        debounce = 600,
        throttle = 600,
      },
      rag_service = {
        enabled = false, -- Enables the RAG service, requires OPENAI_API_KEY to be set
        provider = "openai", -- The provider to use for RAG service (e.g. openai or ollama)
        llm_model = "", -- The LLM model to use for RAG service
        embed_model = "", -- The embedding model to use for RAG service
        endpoint = "https://api.openai.com/v1", -- The API endpoint for RAG service
      },
      vendors = {
        ollama = {
          __inherited_from = "openai",
          endpoint = "http://127.0.0.1:11434/v1",
          model = function()
            -- Current buffer type for model context
            local ft = vim.bo.filetype
            local model = "mistral:latest" -- Default model

            -- Select appropriate model based on filetype
            if ft == "lua" or ft == "python" or ft == "c" or ft == "cpp" or ft == "zig" then
              model = "codellama:7b-instruct" -- Better for code
            end
            return model
          end,
        },
        deepseek = {
          __inherited_from = "openai",
          api_key_name = "DEEPSEEK_API_KEY",
          endpoint = "https://api.deepseek.com",
          model = "deepseek-coder",
        },
        groq = {
          __inherited_from = "openai",
          api_key_name = "GROQ_API_KEY",
          endpoint = "https://api.groq.com/openai/v1/",
          model = "llama-3.3-70b-versatile",
          max_tokens = 32768,
        },
      },
      claude_sonnet_37_extended = {
        __inherited_from = "claude",
        model = "claude-3-7-sonnet-latest",
      },
      claude_sonnet_37 = {
        __inherited_from = "claude",
        model = "claude-3-7-sonnet-latest",
      },
      claude_sonnet_35 = {
        __inherited_from = "claude",
        model = "claude-3-5-sonnet-latest",
      },
      claude_haiku_35 = {
        __inherited_from = "claude",
        model = "claude=-3-5-haiku-latest",
      },
      openai = {
        model = "gpt-4o",
      },
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
          repomap = "_am",
        },
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
    },
  },
}
