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

local nordic = {
  black0 = 0xff191D24,
  black1 = 0xff1E222A,
  black2 = 0xff222630,
  gray0 = 0xff242933,
  gray1 = 0xff2E3440,
  gray2 = 0xff3B4252,
  gray3 = 0xff434C5E,
  gray4 = 0xff4C566A,
  gray5 = 0xff60728A,
  white0_normal = 0xffBBC3D4,
  white0_reduce_blue = 0xffC0C8D8,
  white1 = 0xffD8DEE9,
  white2 = 0xffE5E9F0,
  white3 = 0xffECEFF4,
  blue0 = 0xff5E81AC,
  blue1 = 0xff81A1C1,
  blue2 = 0xff88C0D0,
  cyan = {
    base = 0xff8FBCBB,
    bright = 0xff9FC6C5,
    dim = 0xff80B3B2,
  },
  red = {
    base = 0xffBF616A,
    bright = 0xffC5727A,
    dim = 0xffB74E58,
  },
  orange = {
    base = 0xffD08770,
    bright = 0xffD79784,
    dim = 0xffCB775D,
  },
  yellow = {
    base = 0xffEBCB8B,
    bright = 0xffEFD49F,
    dim = 0xffE7C173,
  },
  green = {
    base = 0xffA3BE8C,
    bright = 0xffB1C89D,
    dim = 0xff97B67C,
  },
  magenta = {
    base = 0xffB48EAD,
    bright = 0xffBE9DB8,
    dim = 0xffA97EA1,
  },
}

local ctp_mocha = {
  rosewater = 0xfff5e0dc,
  flamingo = 0xfff2cdcd,
  pink = 0xfff5c2e7,
  mauve = 0xffcba6f7,
  red = 0xfff38ba8,
  maroon = 0xffeba0ac,
  peach = 0xfffab387,
  yellow = 0xfff9e2af,
  green = 0xffa6e3a1,
  teal = 0xff94e2d5,
  sky = 0xff89dceb,
  sapphire = 0xff74c7ec,
  blue = 0xff89b4fa,
  lavender = 0xffb4befe,
  text = 0xffcdd6f4,
  subtext1 = 0xffbac2de,
  subtext0 = 0xffa6adc8,
  overlay2 = 0xff9399b2,
  overlay1 = 0xff7f849c,
  overlay0 = 0xff6c7086,
  surface2 = 0xff585b70,
  surface1 = 0xff45475a,
  surface0 = 0xff313244,
  base = 0xff1e1e2e,
  mantle = 0xff181825,
  crust = 0xff11111b,
}

local theme = {
  background = rp.base,
  item = transparent,
  border = transparent,
  text = rp.text,
  subtext = rp.muted,
  red = rp.love,
  green = rp.pine,
  yellow = rp.gold,
  blue = rp.foam,
  orange = rp.iris,
  cyan = rp.rose,
}

M.sections = {
  bar = {
    bg = theme.background,
    border = transparent,
  },
  item = {
    bg = theme.item,
    popup = theme.background,
    border = theme.border,
    text = theme.text,
  },
  bracket = {
    bg = theme.item,
    border = transparent,
  },
  popup = {
    bg = theme.background,
    border = transparent,
  },
  apple = {
    icon = theme.red,
    bg = M.with_alpha(theme.red, 0.2),
  },
  menu = {
    fg = theme.text,
    bg = M.with_alpha(theme.text, 0.2),
  },
  spaces = {
    icon = {
      theme.orange,
      theme.red,
      theme.yellow,
      theme.cyan,
      theme.green,
      theme.blue,
    },
  },
  apps = {
    focused = theme.text,
    unfocused = theme.subtext,
  },
  front_app = {
    icon = theme.cyan,
    label = theme.subtext,
  },
  media = {
    label = theme.subtext,
  },
  widgets = {
    battery = {
      low = {
        icon = theme.red,
        bg = M.with_alpha(theme.red, 0.2),
      },
      mid = {
        icon = theme.yellow,
        bg = M.with_alpha(theme.yellow, 0.2),
      },
      high = {
        icon = theme.green,
        bg = M.with_alpha(theme.green, 0.2),
      },
    },
    wifi = {
      icon = theme.blue,
      bg = M.with_alpha(theme.blue, 0.2),
    },
    volume = {
      icon = theme.orange,
      bg = M.with_alpha(theme.orange, 0.2),
      popup = {
        item = theme.subtext,
        highlight = theme.text,
      },
      slider = {
        highlight = theme.text,
        bg = theme.subtext,
        border = theme.border,
      },
    },
    messages = {
      icon = theme.red,
      bg = M.with_alpha(theme.red, 0.2),
    },
  },
  calendar = {
    label = theme.subtext,
  },
}

return M
