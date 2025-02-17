local colors = require("colors").sections.bar

-- Equivalent to the --bar domain
sbar.bar {
  topmost = "window",
  height = 38,
  color = colors.bg,
  padding_right = 4,
  padding_left = 4,
  border_color = colors.border,
  border_width = 0,
  blur_radius = 10,
}
