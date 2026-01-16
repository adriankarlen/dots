local wez = require "wezterm"
local appearance = require "lua.appearance"
local mappings = require "lua.mappings"
local bar = wez.plugin.require "https://github.com/adriankarlen/bar.wezterm"

local c = {}

if wez.config_builder then
  c = wez.config_builder()
end

-- General configurations
c.font = wez.font("Berkeley Mono", { weight = "Medium" })
c.font_rules = {
  {
    italic = true,
    font = wez.font("Berkeley Mono", { weight = "Medium", italic = true }),
  },
}
c.font_size = 15
c.command_palette_font_size = 15
c.command_palette_rows = 15
c.adjust_window_size_when_changing_font_size = false
c.audible_bell = "Disabled"
c.scrollback_lines = 3000
c.default_workspace = "main"
c.max_fps = 240

-- appearance
appearance.apply_to_config(c)

-- keys
mappings.apply_to_config(c)

-- bar
bar.apply_to_config(c, {
  position = "top",
  modules = {
    clock = {
      enabled = false,
    },
    username = {
      icon = "",
    },
  },
})

return c
