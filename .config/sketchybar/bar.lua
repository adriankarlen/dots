local colors = require("colors").sections.bar

-- Equivalent to the --bar domain
sbar.bar {
  topmost = "window",
  position = "left",
  height = 42,
  color = colors.bg,
  y_offset = 10,
  padding_right = 4,
  padding_left = 4,
  border_color = colors.border,
  border_width = 2,
  blur_radius = 20,
  margin = 4,
  corner_radius = 8,
  shadow = true,
}
