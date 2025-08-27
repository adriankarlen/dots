local colors = require("colors").sections

sbar.exec("aerospace list-workspaces --all", function(spaces)
  local space_names = {}
  for space_name in spaces:gmatch "[^\r\n]+" do
    local space = sbar.add("item", "space." .. space_name, {
      position = "left",
      icon = {
        width = 10,
      },
      label = {
        drawing = false,
      },
      background = {
        height = 20,
        color = colors.spaces.inactive,
        corner_radius = 2,
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
            color = not no_app and colors.spaces.unselected or colors.spaces.inactive,
          },
        }
      end)
    end

    space:subscribe("aerospace_workspace_change", function(env)
      local selected = env.FOCUSED_WORKSPACE == space_name
      sbar.animate("circ", 15, function()
        space:set {
          background = {
            color = selected and colors.spaces.selected or colors.spaces.unselected,
            height = selected and 40 or 20,
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
    space_names[space_name] = "space." .. space_name
  end

  local function printTable(t)
    for k, v in pairs(t) do
      print(k, v)
    end
  end

  printTable(space_names)
  sbar.add(
    "bracket",
    { "/space\\..*/" },
    { background = { drawing = true, color = colors.bracket.bg, border_color = colors.bracket.border } }
  )
end)

-- local spaces_indicator = sbar.add("item", {
--   icon = {
--     -- padding_left = 15,
--     -- padding_right = 15,
--     string = icons.switch.on,
--     color = colors.indicator,
--   },
--   label = {
--     drawing = false,
--   },
--   -- padding_right = 8,
-- })
--
-- spaces_indicator:subscribe("swap_menus_and_spaces", function()
--   local currently_on = spaces_indicator:query().icon.value == icons.switch.on
--   spaces_indicator:set {
--     icon = currently_on and icons.switch.off or icons.switch.on,
--   }
-- end)
--
-- spaces_indicator:subscribe("mouse.clicked", function()
--   sbar.trigger "swap_menus_and_spaces"
-- end)
