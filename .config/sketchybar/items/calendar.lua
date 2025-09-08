local settings = require "settings"

local minute = sbar.add("item", {
  label = {
    font = {
      family = settings.font.numbers,
      size = 14.0,
    },
    padding_left = 0,
    padding_right = 0,
  },
  icon = {
    display = false,
    padding_left = 12,
    padding_right = 6,
  },
  position = "right",
  update_freq = 30,
  click_script = "open -a 'Calendar'",
  padding_left = 0,
  padding_right = 8,
})

-- english date
minute:subscribe({ "forced", "routine", "system_woke" }, function(_)
  minute:set { label = os.date "%H:%M" }
end)

