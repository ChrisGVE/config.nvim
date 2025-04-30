-- Integration of go.nvim with Mason
--
require("mason").setup()
require("mason-lspconfig").setup()
require("go").setup({ lsp_cfg = false })
local cfg = require("go.lsp").config()
require("lspconfig").gopls.setup(cfg)
