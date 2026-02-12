local colors = require("colors").sections.bar

-- Equivalent to the --bar domain
sbar.bar {
  topmost = "window",
  position = "top",
  height = 40,
  color = colors.bg,
  y_offset = 0,
  padding_right = 8,
  padding_left = 8,
  border_color = colors.border,
  border_width = 0,
  blur_radius = 0,
  margin = 0,
  corner_radius = 0,
  shadow = false,
}
