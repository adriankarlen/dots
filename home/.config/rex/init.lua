-- dactyl: session picker (sessions, workspaces, zoxide).
require("dactyl").setup {
  keys = { pick = "cmd+k", last = "cmd+shift+k" },
  blacklist = { "^scratch$", "^_" },
  workspaces = {
    { name = "dots", path = "~/dots", startup = "nvim" },
    { name = "downloads", path = "~/Downloads", startup = "yazi" },
  },
  rules = {
    { path_glob = "~/repos/**", startup = "nvim" },
  },
}

-- lazygit in a floating pane, in the focused pane's directory.
rex.action {
  name = "lazygit",
  title = "Lazygit",
  run = function(ctx)
    local p = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id }) or {}
    local _, err = rex.session.new_layer {
      bounds = { 0.05, 0.05, 0.9, 0.9 },
      focus = true,
      layout = rex.layout.block {
        flavor = "com.superlogical.terminal.shell",
        options = { command = { "lazygit" }, cwd = p.foreground and p.foreground.cwd },
      },
    }
    if err ~= nil then
      error(err, 0)
    end
  end,
}
rex.bind("cmd+g", "lazygit")
