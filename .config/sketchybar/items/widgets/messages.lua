local icons = require "icons"
local colors = require("colors").sections.widgets.messages

local messages = sbar.add("item", "widgets.messages", {
  position = "right",
  icon = {
    color = colors.icon,
    string = icons.message,
    padding_right = 4,
  },
  label = { drawing = false },
  background = { drawing = false },
  update_freq = 30,
  padding_left = -4,
})

messages:subscribe({ "routine", "front_app_changed", "space_change", "space_windows_change" }, function(env)
  sbar.exec(
    -- requires full disk access
    [[sqlite3 ~/Library/Messages/chat.db "SELECT COUNT(guid) FROM message WHERE NOT(is_read) AND NOT(is_from_me) AND text !=''"]],
    function(newmess)
      local mess = tonumber(newmess)
      local drawing = false

      if mess > 0 then
        drawing = true
      end

      messages:set {
        icon = {
          drawing = drawing,
        },
        padding_right = drawing and 4 or 0,
      }
    end
  )
end)

messages:subscribe("mouse.clicked", function(env)
  sbar.exec "open -a 'Messages'"
end)
