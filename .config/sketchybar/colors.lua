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

local theme = {
  background = nordic.black1,
  item = transparent,
  border = nordic.black1,
  text = nordic.white0_reduce_blue,
  subtext = nordic.gray4,
  red = nordic.red.base,
  green = nordic.green.base,
  yellow = nordic.yellow.base,
  blue = nordic.blue0,
  magenta = nordic.magenta.base,
  cyan = nordic.cyan.base,
  highlight_low = nordic.gray1,
  highlight_med = nordic.gray2,
  highlight_high = nordic.gray3,
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
    bg = transparent,
  },
  menu = {
    fg = theme.text,
    bg = transparent,
  },
  spaces = {
    icon = {
      theme.magenta,
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
    icon = theme.red,
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
      icon = theme.magenta,
      bg = M.with_alpha(theme.magenta, 0.2),
      popup = {
        item = theme.subtext,
        highlight = theme.text,
      },
      slider = {
        highlight = theme.text,
        bg = theme.highlight_low,
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
