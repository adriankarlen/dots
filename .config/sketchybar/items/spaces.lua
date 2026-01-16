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

for i = 5, 1, -1 do
  local color_index = (math.fmod(i or 0, #colors.spaces.icon - 1) + 1) or 1
  local icon_color = colors.spaces.icon[color_index]
  local space = sbar.add("space", "space." .. i, {
    space = i,
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
  })

  space:subscribe("space_change", function(env)
    local selected = env.SELECTED == "true"
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
