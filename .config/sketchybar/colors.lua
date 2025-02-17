local M = {}

local with_alpha = function(color, alpha)
  if alpha > 1.0 or alpha < 0.0 then
    return color
  end
  return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

local transparent = 0x00000000

local rp_moon = {
  base = 0xff232136,
  surface = 0xff2a273f,
  overlay = 0xff393552,
  muted = 0xff6e6a86,
  subtle = 0xff908caa,
  text = 0xffe0def4,
  love = 0xffeb6f92,
  rose = 0xffea9a97,
  gold = 0xfff6c177,
  iris = 0xffc4a7e7,
  pine = 0xff3e8fb0,
  foam = 0xff9ccfd8,
  highlight_low = 0xff21202e,
  highlight_med = 0xff44415a,
}

M.sections = {
  bar = {
    bg = with_alpha(rp_moon.surface, 0.6),
    border = transparent,
  },
  item = {
    bg = rp_moon.overlay,
    border = rp_moon.highlight_low,
    text = rp_moon.text,
  },
  apple = rp_moon.rose,
  spaces = {
    icon = {
      color = rp_moon.subtle,
      highlight = rp_moon.text,
    },
    label = {
      color = rp_moon.subtle,
      highlight = rp_moon.gold,
    },
    indicator = rp_moon.iris,
  },
  media = {
    label = rp_moon.subtle,
  },
  widgets = {
    battery = {
      low = rp_moon.love,
      mid = rp_moon.gold,
      high = rp_moon.pine,
    },
    wifi = { icon = rp_moon.rose },
    volume = {
      icon = rp_moon.foam,
      popup = {
        item = rp_moon.subtle,
        highlight = rp_moon.text,
      },
      slider = {
        highlight = rp_moon.foam,
        bg = rp_moon.highlight_med,
        border = rp_moon.highlight_low,
      },
    },
    messages = { icon = rp_moon.love },
  },
  calendar = {
    label = rp_moon.subtle,
  },
}

return M
