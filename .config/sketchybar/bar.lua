local colors = require("colors").sections.bar

-- Equivalent to the --bar domain
sbar.bar {
  topmost = "window",
  position = "top",
  height = 37,
  color = colors.bg,
  y_offset = 0,
  padding_right = 4,
  padding_left = 4,
  border_color = colors.border,
  border_width = 0,
  blur_radius = 40,
  margin = 0,
  corner_radius = 0,
  shadow = false,
}
