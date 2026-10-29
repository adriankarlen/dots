-- Custom actions. Bound to keys in config/keys.lua.

local TERMINAL = "com.superlogical.terminal"
local SHELL = "com.superlogical.terminal.shell"

-- lazygit in a floating pane, in the focused pane's directory.
rex.action {
  name = "lazygit",
  title = "Lazygit",
  run = function(ctx)
    local p = rex.block.call(TERMINAL, "process", { block_id = ctx.block_id }) or {}
    local _, err = rex.session.new_layer {
      bounds = { 0.05, 0.05, 0.9, 0.9 },
      focus = true,
      layout = rex.layout.block {
        flavor = SHELL,
        options = { command = { "lazygit" }, cwd = p.foreground and p.foreground.cwd },
      },
    }
    if err ~= nil then
      error(err, 0)
    end
  end,
}

-- `pkgrun <script>` (~/.local/bin/pkgrun) in a background tab named after the
-- script, in the focused pane's directory. It is typed into a shell, so the
-- tab stays open when the script stops.
rex.action {
  name = "pkgrun",
  title = "Run Package Script in Tab",
  description = "Run `pkgrun <script>` (default: dev) in a background tab, using the focused pane's directory.",
  args = { script = "string?" },
  run = function(ctx, args)
    local script = args.script or "dev"
    local p = rex.block.call(TERMINAL, "process", { block_id = ctx.block_id }) or {}
    local _, err = rex.session.new_window {
      window_label = script,
      focus = false,
      layout = rex.layout.block {
        flavor = SHELL,
        options = { cwd = p.foreground and p.foreground.cwd, initial_input = "pkgrun " .. script .. "\n" },
      },
    }
    if err ~= nil then
      error(err, 0)
    end
  end,
}
