local colors = require("colors").sections.bar

-- Equivalent to the --bar domain
sbar.bar {
  topmost = "window",
  height = 42,
  color = colors.bg,
  y_offset = 4,
  padding_right = 4,
  padding_left = 4,
  border_color = colors.border,
  border_width = 2,
  blur_radius = 20,
  margin = 12,
  corner_radius = 8,
}
