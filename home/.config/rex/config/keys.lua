-- Key bindings, modelled on tmux/herdr.
--
-- ctrl+a enters the one-shot `prefix` mode: the next key runs its action and
-- the mode ends. Unbound keys do nothing there, and Escape cancels.
-- `rex keymap` lists everything bound here.
--
-- Keys follow the keyboard layout (Swedish Pro), written without shift
-- applied: `?` is shift + the `+` key, `=` is shift+0.

local PREFIX = "ctrl+a"

---@param key string
---@param action string
---@param args? table
local function prefix(key, action, args)
  rex.bind("prefix/" .. key, action, args)
end

rex.mode("prefix", { exclusive = true })
rex.bind(PREFIX, "client.mode.enter", { name = "prefix", once = true })
-- Press the prefix twice to send it to the terminal.
prefix(PREFIX, "pane.send_key", { key = PREFIX })

-- Tabs ------------------------------------------------------------------------

prefix("c", "client.tab.new")
prefix("p", "client.tab.previous")
prefix("shift+,", "client.tab.rename")
for i = 1, 9 do
  prefix(tostring(i), "client.tab.goto", { index = i })
end
prefix("n", "pkgrun", { script = "dev" })

-- Panes -----------------------------------------------------------------------

prefix("h", "pane.focus.left")
prefix("j", "pane.focus.down")
prefix("k", "pane.focus.up")
prefix("l", "pane.focus.right")
prefix("tab", "pane.focus_next")
prefix("shift+tab", "pane.focus_previous")
prefix("shift+h", "pane.move.left")
prefix("shift+l", "pane.move.right")
prefix("v", "pane.split.right")
prefix("-", "pane.split.down")
prefix("x", "pane.close")
prefix("z", "pane.zoom")
prefix("f", "client.find.open")

-- Resize mode: stays active until Escape or Enter.
rex.mode("resize", { exclusive = true })
prefix("r", "client.mode.enter", { name = "resize" })
for key, direction in pairs { h = "left", j = "down", k = "up", l = "right" } do
  rex.bind("resize/" .. key, "pane.resize", { direction = direction })
  rex.bind("resize/" .. direction, "pane.resize", { direction = direction })
  rex.bind("resize/shift+" .. key, "pane.resize", { direction = direction, amount = 15 })
  rex.bind("resize/shift+" .. direction, "pane.resize", { direction = direction, amount = 15 })
end
rex.bind("resize/shift+0", "pane.balance") -- =
rex.bind("resize/enter", "client.mode.exit")

-- ctrl+h/j/k/l move between Rex panes, but go to (n)vim when it is focused so
-- smart-splits can handle them there.
---@type table<string, boolean>
local VIM = { nvim = true, vim = true }
for key, direction in pairs { h = "left", j = "down", k = "up", l = "right" } do
  rex.bind("ctrl+" .. key, function(ctx)
    if ctx.block_id then
      local p = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
      if p and p.foreground and VIM[p.foreground.name] then
        return false
      end
    end
    rex.session.focus_direction { direction = direction }
    return true
  end)
end

-- Sessions (herdr workspaces) -------------------------------------------------

prefix("t", "dactyl")
prefix("shift+b", "dactyl_last")
prefix("w", "session.switch")
prefix("shift+j", "session.next")
prefix("shift+k", "session.previous")
prefix("shift+n", "session.new")
prefix("shift+w", "session.rename")
prefix("shift+x", "session.close")

rex.bind("cmd+k", "dactyl")
rex.bind("cmd+shift+k", "dactyl_last")

-- Apps and client ---------------------------------------------------------------

prefix("g", "lazygit")
rex.bind("cmd+g", "lazygit")

prefix("b", "client.sidebar.toggle")
prefix("s", "client.settings")
prefix("shift+[Minus]", "client.palette.toggle") -- ?
prefix("shift+r", "client.config.reload")
