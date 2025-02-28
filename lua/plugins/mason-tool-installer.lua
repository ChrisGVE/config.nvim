return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  opts = {
    ensure_installed = {
      "alex", -- text
      "beautysh", -- shells
      "djlint", -- Jinja
      "esbonio", -- Sphinx
      "jinja-lsp", -- Jinja
      "lemminx", -- XML
      "ltex-ls", -- LS to connect to ltex_extra.nvim
      "prettierd", -- formatter
      "selene", -- lua
      "sonarlint-language-server", -- multiple, selected for XML
      "textlint", -- text
      "textlsp", -- Text
      "typos", -- Text
      "typos-lsp", -- Text
      "vale", -- text
      "vale-ls", -- Text
      "woke", -- Text
      "write-good", -- text
      "xmlformatter", -- XML
      "debugpy", -- Python
      "ruff", -- Python
      "mypy", -- Python
      "pydocstyle", -- Python
      "zls", -- Zig
    },
    auto_update = true,
    debounce_hours = 12, -- at least 12 hours between attempts to install/update
  },
}
