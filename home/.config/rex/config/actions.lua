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

-- Like client.tab.goto, but counts only the current session's tabs. The
-- built-in action counts every tab in the horizontal tab bar, across sessions.
rex.action {
  name = "session_tab_goto",
  title = "Go to Tab in Session",
  description = "Show the session's Nth tab. Tabs count from 1, and -1 means the last tab.",
  category = "Tab",
  args = { index = "integer" },
  run = function(ctx, args)
    local view, err = rex.session.view {}
    if view == nil then
      error(err, 0)
    end
    local windows = view.windows or {}
    local w = windows[args.index == -1 and #windows or args.index]
    if w == nil then
      return
    end
    -- The app keeps its own tab selection, so focus_window alone moves the
    -- server's active tab without changing what the app shows.
    rex.client.queue("session.select", { session_id = ctx.session_id, window_id = w.window_id })
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
