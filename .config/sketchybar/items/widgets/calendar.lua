local settings = require "settings"
local colors = require("colors").sections

local minute = sbar.add("item", "widgets.calendar", {
  icon = {
    font = {
      size = 6.0,
    },
    color = colors.calendar.label,
    string = "􀀁",
    padding_left = 6,
    padding_right = 6,
  },
  label = {
    font = {
      family = settings.font.numbers,
    },
    color = colors.calendar.label,
    padding_left = 0,
    padding_right = 0,
  },
  position = "right",
  update_freq = 30,
  click_script = "open -a 'Calendar'",
  padding_left = 0,
  padding_right = 12,
})

-- english date
minute:subscribe({ "forced", "routine", "system_woke" }, function(_)
  minute:set { label = os.date "%H:%M" }
end)
