local icons = require "icons"
local colors = require("colors").sections.media

local spotify = sbar.add("item", {
  position = "right",
  icon = {
    max_chars = 50,
    padding_left = 8,
  },
  popup = {
    horizontal = true,
    align = "center",
    y_offset = 2,
  },
  padding_right = 8,
})

sbar.add("item", {
  position = "popup." .. spotify.name,
  padding_left = 6,
  padding_right = 6,
  icon = { string = icons.media.back },
  label = { drawing = false },
  background = { drawing = false },
  click_script = [[osascript -e 'tell application "Spotify" to play previous track']],
})
sbar.add("item", {
  position = "popup." .. spotify.name,
  padding_left = 6,
  padding_right = 6,
  icon = { string = icons.media.play_pause },
  label = { drawing = false },
  background = { drawing = false },
  click_script = [[osascript -e 'tell application "Spotify" to playpause']],
})
sbar.add("item", {
  position = "popup." .. spotify.name,
  padding_left = 6,
  padding_right = 6,
  icon = { string = icons.media.forward },
  label = { drawing = false },
  background = { drawing = false },
  click_script = [[osascript -e 'tell application "Spotify" to play next track']],
})

sbar.add("event", "playback_state_changed", "com.spotify.client.PlaybackStateChanged")

spotify:subscribe("playback_state_changed", function(env)
  -- local playing = (env.INFO["Player State"] == "Playing")
  local playing = true
  spotify:set { drawing = playing, icon = env.INFO.Artist .. " - " .. env.INFO.Name }
end)

spotify:subscribe("mouse.clicked", function(_)
  spotify:set { popup = { drawing = "toggle" } }
end)
