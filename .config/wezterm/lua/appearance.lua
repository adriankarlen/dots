local wez = require "wezterm"

local M = {}

M.apply_to_config = function(c)
  c.color_scheme = "rose-pine"
  local scheme = wez.color.get_builtin_schemes()[c.color_scheme]

  -- swap green and blue to match correct theme
  local ansi = scheme.ansi
  ansi[3] = "#31748f"
  ansi[5] = "#9ccfd8"

  local brights = scheme.brights
  brights[3] = "#31748f"
  brights[5] = "#9ccfd8"

  c.colors = {
    tab_bar = {
      background = "#1f1d2e",
      active_tab = {
        fg_color = ansi[4],
        bg_color = "#1f1d2e",
      },
      inactive_tab = {
        fg_color = ansi[6],
        bg_color = "#1f1d2e",
      },
    },
    cursor_bg = "#524f67",
    cursor_border = "#524f67",
    cursor_fg = scheme.foreground,
    selection_bg = "#403d52",
    split = scheme.ansi[7],
    ansi = ansi,
    brights = brights,
    compose_cursor = scheme.ansi[2]
  }
  c.command_palette_bg_color = "#26233a"
  c.command_palette_fg_color = scheme.foreground
  c.inactive_pane_hsb = { brightness = 0.9 }
  c.window_padding = { left = "1cell", right = "1cell", top = 0, bottom = "1cell" }
  c.window_decorations = "RESIZE"
  c.window_background_opacity = 0.95
  c.show_new_tab_button_in_tab_bar = false
end

return M
