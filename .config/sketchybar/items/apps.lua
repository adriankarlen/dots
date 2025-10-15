local colors = require("colors").sections
local icon_map = require "helpers.icon_map"

-- local apps = {},
--
-- for _, app in ipairs(settings.apps) do


  -- local function update_apps()
  --   sbar.exec("aerospace list-windows --format %{app-name} --workspace --focused", function(windows)
  --     local seen = {}
  --     for app in windows:gmatch "[^\r\n]+" do
  --       if not seen[app] then
  --         seen[app] = true
  --         if not sbar.exists("app." .. app) then
  --           local lookup = icon_map[app]
  --           local icon = ((lookup == nil) and icon_map["default"] or lookup)
  --           sbar.add("item", "app." .. app, {
  --             position = "e",
  --             icon = {
  --               font = {
  --                 font = "sketchybar-app-font-bg:Regular:14.0",
  --                 string = icon,
  --                 color = colors.apps.unfocused,
  --                 highlight_color = colors.apps.focused,
  --               },
  --               label = {
  --                 drawing = false,
  --               },
  --               background = {
  --                 drawing = false,
  --               },
  --             },
  --           })
  --         end
  --       end
  --     end
  --   end)
  -- end
  -- subscribe("front_app_switched", function(env)
  --   sbar.remove { "/app\\..*/" }
  --   update_apps()
  -- end)
