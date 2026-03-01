local function runtime_doc_dirs()
  local dirs = {}
  for _, dir in ipairs(vim.api.nvim_get_runtime_file("doc", true)) do
    if vim.fn.isdirectory(dir) == 1 then
      dirs[#dirs + 1] = dir
    end
  end
  return dirs
end

return {
  {
    "OXY2DEV/helpview.nvim",
    lazy = false,
    opts = {
      preview = {
        enable = true,
        enable_hybrid_mode = true,
        icon_provider = "devicons",
      },
    },
  },
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>sh",
        function()
          Snacks.picker.help()
        end,
        desc = "Help Pages",
      },
      {
        "<leader>sH",
        function()
          Snacks.picker.grep({
            title = "Help Grep",
            dirs = runtime_doc_dirs(),
          })
        end,
        desc = "Help Grep",
      },
    },
  },
}
