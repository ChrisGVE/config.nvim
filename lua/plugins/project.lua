local EXCLUDE_DIRS = {}
for _, path in ipairs({
  os.getenv("XDG_DATA_HOME") or vim.fn.stdpath("data"),
  os.getenv("XDG_STATE_HOME") or vim.fn.stdpath("state"),
  os.getenv("XDG_CACHE_HOME") or vim.fn.stdpath("cache"),
}) do
  if type(path) == "string" and path ~= "" then
    EXCLUDE_DIRS[#EXCLUDE_DIRS + 1] = path
  end
end

return {
  "ahmedkhalf/project.nvim",
  opts = {
    manual_mode = false,
    exclude_dirs = EXCLUDE_DIRS,
  },
}
