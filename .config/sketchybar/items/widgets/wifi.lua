local icons = require "icons"
local colors = require("colors").sections.widgets.wifi

-- Execute the event provider binary which provides the event "network_update"
-- for the network interface "en0", which is fired every 2.0 seconds.
sbar.exec "killall network_load >/dev/null; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load en0 network_update 2.0"

local popup_width = 250

local wifi = sbar.add("item", "widgets.wifi", {
  position = "right",
  icon = {
    color = colors.icon,
  },
  label = { drawing = false },
  background = { drawing = false },
  popup = {
    align = "center",
    height = 30,
    y_offset = 2,
  },
  padding_left = 4,
  padding_right = 0,
})

local ip = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    align = "left",
    string = "IP:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
  background = { drawing = false },
})

local mask = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    align = "left",
    string = "Subnet mask:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
  background = { drawing = false },
})

local router = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    align = "left",
    string = "Router:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
  background = { drawing = false },
})

wifi:subscribe({ "wifi_change", "system_woke" }, function(env)
  sbar.exec([[ipconfig getsummary en1 | awk -F ' SSID : '  '/ SSID : / {print $2}']], function(wifi_name)
    local connected = not (wifi_name == "")
    wifi:set {
      icon = {
        string = connected and icons.wifi.connected or icons.wifi.disconnected,
      },
    }

    -- VPN icon
    sbar.exec([[sleep 2; scutil --nwi | grep -m1 'utun' | awk '{ print $1 }']], function(vpn)
      local vpnconnected = not (vpn == "")

      if vpnconnected then
        Wifi_icon = icons.wifi.vpn
        Wifi_color = colors.green
      end

      wifi:set {
        icon = {
          string = Wifi_icon,
          color = Wifi_color,
        },
      }
    end)
  end)
end)

local function hide_details()
  wifi:set { popup = { drawing = false } }
end

local function toggle_details()
  local should_draw = wifi:query().popup.drawing == "off"
  if should_draw then
    wifi:set { popup = { drawing = true } }
    sbar.exec("ipconfig getifaddr en1", function(result)
      ip:set { label = result }
    end)
    sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(result)
      mask:set { label = result }
    end)
    sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
      router:set { label = result }
    end)
  else
    hide_details()
  end
end

wifi:subscribe("mouse.clicked", function()
  -- sbar.animate("tanh", 8, function()
  -- 	wifi:set({
  -- 		background = {
  -- 			shadow = {
  -- 				distance = 0,
  -- 			},
  -- 		},
  -- 		y_offset = -4,
  -- 		padding_left = 8,
  -- 		padding_right = 0,
  -- 	})
  -- 	wifi:set({
  -- 		background = {
  -- 			shadow = {
  -- 				distance = 4,
  -- 			},
  -- 		},
  -- 		y_offset = 0,
  -- 		padding_left = 4,
  -- 		padding_right = 4,
  -- 	})
  -- end)
  toggle_details()
end)

-- wifi:subscribe("mouse.exited.global", hide_details)

local function copy_label_to_clipboard(env)
  local label = sbar.query(env.NAME).label.value
  sbar.exec('echo "' .. label .. '" | pbcopy')
  sbar.set(env.NAME, { label = { string = icons.clipboard, align = "center" } })
  sbar.delay(1, function()
    sbar.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end

ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)
