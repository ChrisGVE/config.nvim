local prose_filetypes = {
  "asciidoc",
  "gitcommit",
  "mail",
  "markdown",
  "mdx",
  "org",
  "pandoc",
  "plaintex",
  "quarto",
  "rmd",
  "rnoweb",
  "rst",
  "tex",
  "text",
  "typst",
}

local code_filetypes = {
  "c",
  "cmake",
  "cpp",
  "cs",
  "dart",
  "go",
  "haskell",
  "java",
  "javascript",
  "lua",
  "nix",
  "php",
  "python",
  "ruby",
  "rust",
  "sh",
  "swift",
  "toml",
  "typescript",
  "typescriptreact",
}

local prose_filetype_lookup = {}
for _, ft in ipairs(prose_filetypes) do
  prose_filetype_lookup[ft] = true
end

local function in_comment_context()
  local ok, node = pcall(vim.treesitter.get_node, { ignore_injections = false })
  if not ok or not node then
    return false
  end

  while node do
    local node_type = node:type()
    if node_type and node_type:find("comment", 1, true) then
      return true
    end
    node = node:parent()
  end

  return false
end

local function prose_or_comment()
  return prose_filetype_lookup[vim.bo.filetype] or in_comment_context()
end

local dictionary_files = {}
for _, path in ipairs({
  vim.fn.expand("~/.config/nvim/spell/en.utf-8.add"),
  "/usr/share/dict/words",
  "/usr/share/dict/web2",
}) do
  if vim.fn.filereadable(path) == 1 then
    table.insert(dictionary_files, path)
  end
end

return {
  {
    "LazyVim/LazyVim",
    init = function()
      vim.opt.spelllang = { "en" }
      pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("prose_wrap_spell", { clear = true }),
        pattern = prose_filetypes,
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.spell = true
        end,
      })
    end,
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "harper-ls",
        "ltex-ls-plus",
        "typos-lsp",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      opts.servers.ltex_plus = vim.tbl_deep_extend("force", opts.servers.ltex_plus or {}, {
        filetypes = prose_filetypes,
        settings = {
          ltex = {
            language = "en-US",
          },
        },
      })

      opts.servers.harper_ls = vim.tbl_deep_extend("force", opts.servers.harper_ls or {}, {
        filetypes = code_filetypes,
      })

      opts.servers.typos_lsp = vim.tbl_deep_extend("force", opts.servers.typos_lsp or {}, {
        filetypes = code_filetypes,
      })

      opts.servers.marksman = { enabled = false }
      opts.servers.textlsp = { enabled = false }
      opts.servers.vale_ls = { enabled = false }
    end,
  },

  {
    "saghen/blink.cmp",
    dependencies = {
      "ribru17/blink-cmp-spell",
      {
        "Kaiser-Yang/blink-cmp-dictionary",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.per_filetype = opts.sources.per_filetype or {}

      opts.sources.providers.spell = vim.tbl_deep_extend("force", opts.sources.providers.spell or {}, {
        module = "blink-cmp-spell",
        name = "Spell",
        score_offset = 70,
        opts = {
          preselect_correct_word = true,
          use_cmp_spell_sorting = true,
          enable_in_context = prose_or_comment,
        },
      })

      if #dictionary_files > 0 then
        opts.sources.providers.dictionary = vim.tbl_deep_extend("force", opts.sources.providers.dictionary or {}, {
          module = "blink-cmp-dictionary",
          name = "Dictionary",
          score_offset = 60,
          min_keyword_length = 3,
          enabled = function()
            return prose_filetype_lookup[vim.bo.filetype] == true
          end,
          opts = {
            dictionary_files = dictionary_files,
          },
        })
      end

      local default_sources = opts.sources.default
      opts.sources.default = function()
        local sources = {}
        if type(default_sources) == "function" then
          sources = default_sources()
        elseif type(default_sources) == "table" then
          sources = vim.deepcopy(default_sources)
        end
        if not vim.tbl_contains(sources, "spell") then
          table.insert(sources, "spell")
        end
        return sources
      end

      for _, ft in ipairs(prose_filetypes) do
        local per_filetype = opts.sources.per_filetype[ft]
        if type(per_filetype) ~= "table" then
          per_filetype = { inherit_defaults = true }
          opts.sources.per_filetype[ft] = per_filetype
        end
        per_filetype.inherit_defaults = per_filetype.inherit_defaults ~= false
        if #dictionary_files > 0 and not vim.tbl_contains(per_filetype, "dictionary") then
          table.insert(per_filetype, "dictionary")
        end
      end
    end,
  },

  {
    "folke/noice.nvim",
    opts_extend = { "routes" },
    opts = {
      routes = {
        {
          filter = {
            event = "lsp",
            kind = "progress",
            cond = function(_message)
              return prose_filetype_lookup[vim.bo.filetype] == true
            end,
          },
          opts = { skip = true },
        },
      },
    },
  },
}
