local wez = require "wezterm"
local act = wez.action
local callback = wez.action_callback

local mod = {
  c = "CTRL",
  s = "SHIFT",
  a = "ALT",
  l = "LEADER",
}

local keybind = function(mods, key, action)
  return { mods = table.concat(mods, "|"), key = key, action = action }
end

local M = {}

local leader = { mods = mod.c, key = "a", timeout_miliseconds = 1000 }

local keys = function()
  local keys = {
    -- CTRL-A, CTRL-A sends CTRL-A
    keybind({ mod.l, mod.c }, "a", act.SendString "\x01"),

    -- pane and tabs
    keybind({ mod.l }, "ö", act.SplitVertical { domain = "CurrentPaneDomain" }),
    keybind({ mod.l }, "ä", act.SplitHorizontal { domain = "CurrentPaneDomain" }),
    keybind({ mod.l }, "z", act.TogglePaneZoomState),
    keybind({ mod.l }, "c", act.SpawnTab "CurrentPaneDomain"),
    keybind({ mod.l }, "h", act.ActivatePaneDirection "Left"),
    keybind({ mod.l }, "j", act.ActivatePaneDirection "Down"),
    keybind({ mod.l }, "k", act.ActivatePaneDirection "Up"),
    keybind({ mod.l }, "l", act.ActivatePaneDirection "Right"),
    keybind({ mod.l }, "x", act.CloseCurrentPane { confirm = true }),
    keybind({ mod.l, mod.s }, "H", act.AdjustPaneSize { "Left", 5 }),
    keybind({ mod.l, mod.s }, "J", act.AdjustPaneSize { "Down", 5 }),
    keybind({ mod.l, mod.s }, "K", act.AdjustPaneSize { "Up", 5 }),
    keybind({ mod.l, mod.s }, "L", act.AdjustPaneSize { "Right", 5 }),
    keybind({ mod.l, mod.s }, "&", act.CloseCurrentTab { confirm = true }),
    keybind(
      { mod.l },
      "e",
      act.PromptInputLine {
        description = wez.format {
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "Renaming Tab Title...:" },
        },
        action = callback(function(win, _, line)
          if line == "" then
            return
          end
          win:active_tab():set_title(line)
        end),
      }
    ),

    -- workspaces
    keybind({ mod.l }, "w", act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" }),

    -- copy and paste
    keybind({ mod.c, mod.s }, "c", act.CopyTo "Clipboard"),
    keybind({ mod.c, mod.s }, "v", act.PasteFrom "Clipboard"),

    -- launch spotify_player as a small pane in the bottom
    keybind(
      { mod.l },
      "s",
      act.SplitPane {
        direction = "Down",
        command = { args = { "spotify_player" } },
        size = { Cells = 6 },
      }
    ),

    -- update all plugins
    keybind(
      { mod.l },
      "u",
      callback(function(win)
        wez.plugin.update_all()
        win:toast_notification("wezterm", "plugins updated!", nil, 4000)
      end)
    ),

    -- keybind(
    --   { mod.l },
    --   "r",
    --   act.PromptInputLine {
    --     description = wez.format {
    --       { Attribute = { Intensity = "Bold" } },
    --       { Foreground = { AnsiColor = "Teal" } },
    --       { Text = "Enter run command: " },
    --     },
    --     action = callback(function(_, _, line)
    --       if line == "" then
    --         return
    --       end
    --       act.SplitPane {
    --         direction = "Down",
    --         command = { args = { line } },
    --         size = { Cells = 10 },
    --       }
    --     end),
    --   }
    -- ),
  }

  -- tab navigation
  for i = 1, 9 do
    table.insert(keys, keybind({ mod.l }, tostring(i), act.ActivateTab(i - 1)))
  end
  return keys
end

M.apply_to_config = function(c)
  c.treat_left_ctrlalt_as_altgr = true
  c.leader = leader
  c.keys = keys()
end

return M
