local colors = require("colors").sections
local icons = require "icons"

sbar.add("item", "system.apple", {
  padding_left = 4,
  icon = {
    font = { size = 14 },
    string = icons.apple,
    padding_right = 4,
    padding_left = 4,
    color = colors.apple.icon,
  },
  background = {
    color = colors.apple.bg,
    corner_radius = 9999,
  },
  label = { drawing = false },
  click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})
