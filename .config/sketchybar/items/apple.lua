local colors = require("colors").sections
local icons = require "icons"

sbar.add("item", {
  icon = {
    font = { size = 18 },
    string = icons.apple,
    padding_right = 8,
    padding_left = 8,
    color = colors.apple,
  },
  background = {
    drawing = false,
  },
  label = { drawing = false },
  click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

-- apple:subscribe("mouse.clicked", function()
--   sbar.animate("tanh", 8, function()
--     apple:set {
--       background = {
--         shadow = {
--           distance = 0,
--         },
--       },
--       y_offset = -4,
--       padding_left = 8,
--       padding_right = 0,
--     }
--     apple:set {
--       background = {
--         shadow = {
--           distance = 4,
--         },
--       },
--       y_offset = 0,
--       padding_left = 4,
--       padding_right = 4,
--     }
--   end)
-- end)
