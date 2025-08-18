local colors = require("colors").sections
local icons = require "icons"

sbar.add("item", {
  icon = {
    font = { size = 18 },
    string = icons.apple,
    padding_right = 6,
    padding_left = 6,
    color = colors.apple.icon,
  },
  background = {
    color = colors.apple.bg,
    corner_radius = 8,
  },
  label = { drawing = false },
  click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})
