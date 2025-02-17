require "items.widgets.messages"
require "items.widgets.volume"
require "items.widgets.wifi"
-- require "items.widgets.battery"

sbar.add("bracket", { "/widgets\\..*/" }, {})

sbar.add("item", "widget.padding", {
  width = 16,
})
