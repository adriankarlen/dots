local colors = require("colors").sections.spaces
local icons = require "icons"
local icon_map = require "helpers.icon_map"

sbar.exec("aerospace list-workspaces --all", function(spaces)
  for space_name in spaces:gmatch "[^\r\n]+" do
    local space = sbar.add("item", "space." .. space_name, {
      position = "left",
      icon = {
        width = 8,
      },
      label = {
        drawing = false,
      },
      background = {
        color = colors.inactive,
        height = 8,
        corner_radius = 4,
        padding_left = space_name == "1" and 0 or 4,
        padding_right = 4,
      },
      click_script = "aerospace workspace " .. space_name,
    })

    local function update_windows(focused)
      if focused then
        return
      end

      sbar.exec("aerospace list-windows --format %{app-name} --workspace " .. space_name, function(windows)
        local no_app = true
        for app in windows:gmatch "[^\r\n]+" do
          no_app = false
        end
        space:set {
          background = {
            color = not no_app and colors.unselected or colors.inactive,
          }
        }
      end)
    end

    space:subscribe("aerospace_workspace_change", function(env)
      local selected = env.FOCUSED_WORKSPACE == space_name
      sbar.animate("circ", 15, function()
        space:set {
          icon = { width = selected and 48 or 8 },
          background = {
            color = selected and colors.selected or colors.unselected,
          },
        }
      end)
      update_windows(selected)
    end)

    -- space:subscribe("aerospace_focus_change", function()
    --   update_windows()
    -- end)
    --
    -- space:subscribe("space_windows_change", function()
    --   update_windows()
    -- end)
  end
end)

local spaces_indicator = sbar.add("item", {
  icon = {
    padding_left = 15,
    padding_right = 15,
    string = icons.switch.on,
    color = colors.indicator,
  },
  label = {
    drawing = false,
  },
  padding_right = 8,
})

spaces_indicator:subscribe("swap_menus_and_spaces", function()
  local currently_on = spaces_indicator:query().icon.value == icons.switch.on
  spaces_indicator:set {
    icon = currently_on and icons.switch.off or icons.switch.on,
  }
end)

spaces_indicator:subscribe("mouse.clicked", function()
  sbar.trigger "swap_menus_and_spaces"
end)
