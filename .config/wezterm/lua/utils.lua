local M = {}
local editors = {
  "nvim",
}
local wezterm = require('wezterm')

local function is_found(str, pattern)
   return string.find(str, pattern) ~= nil
end

M.platform = function()
   local is_win = is_found(wezterm.target_triple, 'windows')
   local is_linux = is_found(wezterm.target_triple, 'linux')
   local is_mac = is_found(wezterm.target_triple, 'apple')
   local os = is_win and 'windows' or is_linux and 'linux' or is_mac and 'mac' or 'unknown'
   return {
      os = os,
      is_win = is_win,
      is_linux = is_linux,
      is_mac = is_mac,
   }
end

M.basename = function(s)
  if type(s) ~= "string" then
    return nil
  end
  return s:gsub("(.*[/\\])(.*)%.(.*)", "%2")
end

M.is_an_editor = function(name)
  if type(name) ~= "string" then
    return nil
  end
  for _, editor in pairs(editors) do
    if name == editor then
      return true
    end
    if name == editor .. ".exe" then
      return true
    end
  end
  return false
end

M.is_vim = function(pane)
  -- This is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == "true"
end

return M
