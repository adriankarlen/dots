local colors = require("colors").sections
local icons = require "icons"

local media = sbar.add("item", "widgets.media", {
  position = "right",
  icon = {
    display = false,
  },
  label = {
    max_chars = 50,
    padding_left = 8,
    color = colors.media.label,
  },
  popup = {
    horizontal = true,
    align = "center",
    y_offset = 2,
  },
  padding_right = 16,
  padding_left = 4,
})

sbar.add("item", {
  position = "popup." .. media.name,
  padding_left = 6,
  padding_right = 6,
  icon = { string = icons.media.back },
  label = { drawing = false },
  background = { drawing = false },
  click_script = "media-control previous-track",
})
sbar.add("item", {
  position = "popup." .. media.name,
  padding_left = 6,
  padding_right = 6,
  icon = { string = icons.media.play_pause },
  label = { drawing = false },
  background = { drawing = false },
  click_script = "media-control toggle-play-pause",
})
sbar.add("item", {
  position = "popup." .. media.name,
  padding_left = 6,
  padding_right = 6,
  icon = { string = icons.media.forward },
  label = { drawing = false },
  background = { drawing = false },
  click_script = "media-control next-track",
})

media:subscribe("media_stream_changed", function(env)
  media:set { label = env.artist .. " - " .. env.title }
end)

media:subscribe("mouse.clicked", function(_)
  media:set { popup = { drawing = "toggle" } }
end)
