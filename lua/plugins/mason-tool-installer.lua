return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  opts = {
    ensure_installed = {
      "beautysh", -- shells
      "djlint", -- Jinja
      "esbonio", -- Sphinx
      "jinja-lsp", -- Jinja
      "lemminx", -- XML
      "prettierd", -- formatter
      "selene", -- lua
      "sonarlint-language-server", -- multiple, selected for XML
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
