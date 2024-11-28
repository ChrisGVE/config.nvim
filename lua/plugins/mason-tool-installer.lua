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
      "ltex-ls", -- Latex
      "prettierd", -- formatter
      "selene", -- lua
      "sonarlint-language-server", -- multiple, selected for XML
      "swiftlint", -- Swift
      "textlint", -- text
      "textlsp", -- Text
      "typos", -- Text
      "typos-lsp", -- Text
      "vale", -- text
      "vale-ls", -- Text
      "vim-language-server", -- VimScript
      "vint", -- VimScript
      "woke", -- Text
      "write-good", -- text
      "xmlformatter", -- XML
      "debugpy", -- Python
      "ruff", -- Python
      "mypy", -- Python
      "pydocstyle", -- Python
      "nixpkgs-fmt", -- Nix
      "rnix-lsp", -- Nix
    },
    auto_update = true,
    debounce_hours = 12, -- at least 12 hours between attempts to install/update
  },
}
