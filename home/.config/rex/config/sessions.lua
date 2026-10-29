-- dactyl: session picker (sessions, workspaces, zoxide).
-- Keys are bound in config/keys.lua.
require("plugins.dactyl").setup {
  keys = { pick = false, last = false },
  blacklist = { "^scratch$", "^_" },
  workspaces = {
    { name = "dots", path = "~/dots", startup = "nvim" },
    { name = "downloads", path = "~/Downloads", startup = "yazi" },
  },
  rules = {
    { path_glob = "~/repos/**", startup = "nvim" },
  },
}
