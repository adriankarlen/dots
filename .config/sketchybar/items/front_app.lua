local colors = require("colors").sections
local icon_map = require "helpers.icon_map"

sbar.add("item", "e_bracket.padding", {
  position = "e",
  background = {
    drawing = false,
  },
  width = 12,
})
local front_app = sbar.add("item", "front_app", {
  position = "e",
  display = "active",
  icon = {
    padding_left = 8,
    font = "sketchybar-app-font:Regular:14.0",
    string = "app",
    padding_right = 4,
    color = colors.front_app.icon,
  },
  label = {
    pading_left = 4,
    padding_right = 8,
    color = colors.front_app.label,
  },
  background = {
    drawing = false,
  },
  updates = true,
})

sbar.add("bracket", { "/front\\_app/" }, {
  background = {
    color = colors.bracket.bg,
    height = 34,
    border_color = colors.bracket.border,
    corner_radius = 9999,
  },
})

front_app:subscribe("front_app_switched", function(env)
  local app = env.INFO
  front_app:set {
    icon = {
      string = (icon_map[app] or icon_map["default"]),
    },
    label = {
      string = env.INFO,
    },
  }
end)
