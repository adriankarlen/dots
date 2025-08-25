_G.tools = _G.tools or {}

tools.hl_str = function(group, str)
  return string.format("%%#%s#%s%%*", group, str)
end

tools.root = function()
  local git_path = vim.fn.finddir(".git", ".;")
  return vim.fn.fnamemodify(git_path, ":h")
end

