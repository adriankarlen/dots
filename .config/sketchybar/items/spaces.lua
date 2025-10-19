local with_alpha = require("colors").with_alpha
local colors = require("colors").sections
local icons = require "icons"

sbar.add("item", "q_bracket.padding", {
  position = "q",
  background = {
    drawing = false,
  },
  width = 12,
})
sbar.exec("aerospace list-workspaces --all", function(spaces)
  for space_name in string.reverse(spaces):gmatch "[^\r\n]+" do
    local icon_index = math.fmod(tonumber(space_name) or 1, 6)
    local icon_color = colors.spaces.icon[math.fmod(icon_index, #colors.spaces.icon)]
    local space = sbar.add("item", "space." .. space_name, {
      position = "q",
      icon = {
        color = icon_color,
        string = icons.space_indicator.off,
        padding_left = 5,
        padding_right = 7,
      },
      label = {
        drawing = false,
      },
      background = {
        color = with_alpha(icon_color, 0.2),
        corner_radius = 9999,
      },
      click_script = "aerospace workspace " .. space_name,
    })

    space:subscribe("aerospace_workspace_change", function(env)
      local selected = env.FOCUSED_WORKSPACE == space_name
      sbar.animate("circ", 15, function()
        space:set {
          icon = {
            string = selected and icons.space_indicator.on or icons.space_indicator.off,
          },
        }
      end)
    end)
  end

  sbar.add("bracket", { "/space\\..*/" }, {
    background = {
      height = 34,
      color = colors.bracket.bg,
      border_color = colors.bracket.border,
      corner_radius = 9999,
    },
  })
end)

local spaces_indicator = sbar.add("item", "system.spaces_indicator", {
  icon = {
    string = icons.switch.on,
    color = colors.menu.fg,
    padding_left = 8,
    padding_right = 8,
  },
  label = {
    drawing = false,
  },
  background = {
    color = colors.menu.bg,
    corner_radius = 9999,
  },
  padding_left = 4,
})

spaces_indicator:subscribe("display_menu", function()
  local currently_on = spaces_indicator:query().icon.value == icons.switch.on
  spaces_indicator:set {
    icon = currently_on and icons.switch.off or icons.switch.on,
  }
end)

spaces_indicator:subscribe("mouse.clicked", function()
  sbar.trigger "display_menu"
end)
