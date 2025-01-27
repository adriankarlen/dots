local M = {}
local uv = vim.loop

M.is_win = function()
  uv.os_uname().version:match "Windows"
end

M.root = function()
  local git_path = vim.fn.finddir(".git", ".;")
  return vim.fn.fnamemodify(git_path, ":h")
end

return M
