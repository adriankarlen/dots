local M = {}

local git_path = vim.fn.finddir(".git", ".;")
M.root = function()
  return vim.fn.fnamemodify(git_path, ":h")
end

return M
