local M = {}

M.with_alpha = function(color, alpha)
  if alpha > 1.0 or alpha < 0.0 then
    return color
  end
  return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

local transparent = 0x00000000

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
    bg = transparent,
    border = transparent,
  },
  item = {
    bg = transparent,
    popup = M.with_alpha(theme.base, 0.8),
    border = theme.base,
    text = theme.text,
  },
  bracket = {
    bg = M.with_alpha(theme.base, 0.7),
    border = theme.highlight_low,
  },
  apple = {
    bg = M.with_alpha(theme.love, 0.2),
    icon = theme.love,
  },
  menu = {
    fg = theme.text,
    bg = M.with_alpha(theme.text, 0.2),
  },
  spaces = {
    icon = {
      theme.love,
      theme.gold,
      theme.rose,
      theme.pine,
      theme.foam,
      theme.iris,
    },
  },
  apps = {
    focused = theme.text,
    unfocused = theme.subtle,
  },
  front_app = {
    icon = theme.iris,
    label = theme.subtle,
  },
  media = {
    label = theme.subtle,
  },
  widgets = {
    battery = {
      low = {
        icon = theme.love,
        bg = M.with_alpha(theme.love, 0.2),
      },
      mid = {
        icon = theme.gold,
        bg = M.with_alpha(theme.gold, 0.2),
      },
      high = {
        icon = theme.pine,
        bg = M.with_alpha(theme.pine, 0.2),
      },
    },
    wifi = {
      icon = theme.foam,
      bg = M.with_alpha(theme.foam, 0.2),
    },
    volume = {
      icon = theme.rose,
      bg = M.with_alpha(theme.rose, 0.2),
      popup = {
        item = theme.subtle,
        highlight = theme.text,
      },
      slider = {
        highlight = theme.text,
        bg = theme.highlight_med,
        border = theme.highlight_low,
      },
    },
    messages = {
      icon = theme.love,
      bg = M.with_alpha(theme.love, 0.2),
    },
  },
  calendar = {
    label = theme.subtle,
  },
}

return M
