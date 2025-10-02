local colors = require("colors").sections

require "items.widgets.calendar"
require "items.widgets.volume"
require "items.widgets.messages"
require "items.widgets.wifi"
require "items.widgets.battery"
require "items.widgets.media"

sbar.add("bracket", { "/widgets\\..*/" }, {
  background = {
    color = colors.bracket.bg,
    height = 34,
    border_color = colors.bracket.border,
    corner_radius = 9999,
  },
})

sbar.add("item", "widget.padding", {
  width = 16,
})
