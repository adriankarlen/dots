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
  gold = 0xfff6c177,
  rose = 0xffea9a97,
  iris = 0xffc4a7e7,
  pine = 0xff3e8fb0,
  foam = 0xff9ccfd8,
  highlight_low = 0xff21202e,
  highlight_med = 0xff44415a,
}

local rp = {
  base = 0xff191724,
  surface = 0xff1f1d2e,
  overlay = 0xff26233a,
  muted = 0xff6e6a86,
  subtle = 0xff908caa,
  text = 0xffe0def4,
  love = 0xffeb6f92,
  gold = 0xfff6c177,
  rose = 0xffebbcba,
  iris = 0xffc4a7e7,
  pine = 0xff31748f,
  foam = 0xff9ccfd8,
  highlight_low = 0xff21202e,
  highlight_med = 0xff403d52,
  highlight_high = 0xff524f67,
}

local theme = rp

M.sections = {
  bar = {
    bg = with_alpha(rp_moon.base, 0.6),
    border = theme.highlight_low,
  },
  item = {
    bg = transparent,
    popup = with_alpha(rp_moon.base, 0.8),
    border = theme.base,
    text = theme.text,
  },
  apple = {
    bg = transparent,
    icon = theme.text,
  },
  spaces = {
    inactive = theme.highlight_med,
    unselected = theme.text,
    selected = theme.rose,
  },
  media = {
    label = theme.subtle,
  },
  widgets = {
    battery = {
      low = theme.love,
      mid = theme.gold,
      high = theme.pine,
    },
    wifi = { icon = theme.rose },
    volume = {
      icon = theme.foam,
      popup = {
        item = theme.subtle,
        highlight = theme.text,
      },
      slider = {
        highlight = theme.foam,
        bg = theme.highlight_med,
        border = theme.highlight_low,
      },
    },
    messages = { icon = theme.love },
  },
  calendar = {
    label = theme.subtle,
  },
}

return M
