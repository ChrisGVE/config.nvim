-- This code comes from LazyVim.plugins.extras.editor.dial.lua
local M = {}

---@param increment boolean
---@param g? boolean
function M.dial(increment, g)
  local mode = vim.fn.mode(true)
  -- Use visual commands for VISUAL 'v', VISUAL LINE 'V' and VISUAL BLOCK '\'
  local is_visual = mode == "v" or mode == "V" or mode == "\22"
  local func = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
  local group = vim.g.dials_by_ft[vim.bo.filetype] or "default"
  return require("dial.map")[func](group)
end

return {
  "monaqa/dial.nvim",
  -- stylua: ignore
  keys = {
    -- change the keys to prevent interference with wezterm
    { "<C-c>", function() return M.dial(true) end, expr = true, desc = "Increment", mode = {"n", "v"} },
    { "g<C-c>", function() return M.dial(true, true) end, expr = true, desc = "Increment", mode = {"n", "v"} },
  },
}
