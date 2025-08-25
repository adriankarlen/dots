local settings = require "settings"

local hour = sbar.add("item", {
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      padding_left = 0,
      padding_right = 0,
    },
  },
  icon = {
    display = false,
    padding_left = 0,
    padding_right = 0,
  },
  position = "right",
  update_freq = 30,
  click_script = "open -a 'Calendar'",
  padding_left = 0,
  padding_right = 0,
})

local minute = sbar.add("item", {
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
    },
    padding_left = 0,
    padding_right = 0,
  },
  icon = {
    display = false,
    padding_left = 0,
    padding_right = 0,
  },
  y_offset = -4,
  padding_left = 0,
  padding_right = 0,
  position = "right",
  update_freq = 30,
  click_script = "open -a 'Calendar'",
})

-- english date
hour:subscribe({ "forced", "routine", "system_woke" }, function(_)
  hour:set { label = os.date "%H" }
end)

minute:subscribe({ "forced", "routine", "system_woke" }, function(_)
  minute:set { label = os.date "%M" }
end)
