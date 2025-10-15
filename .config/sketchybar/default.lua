local settings = require "settings"
local colors = require("colors").sections

-- Equivalent to the --default domain
sbar.default {
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 14.0,
    },
    color = colors.item.text,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
    background = { image = { corner_radius = 14 } },
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 14.0,
    },
    color = colors.item.text,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  background = {
    height = 26,
    corner_radius = 4,
    color = colors.item.bg,
    border_color = colors.item.border,
  },
  popup = {
    background = {
      color = colors.popup.bg,
      border_color = colors.popup.border,
      border_width = 2,
      corner_radius = 17,
    },
  },
  padding_left = 4,
  padding_right = 4,
  scroll_texts = true,
}
