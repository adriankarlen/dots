#!/usr/bin/env bash

#################################
# Script to customize gum cli (https://github.com/charmbracelet/gum) with Catppuccin theme colors.
#
# Script will exchange signature gum pink for your favorite accent color.
#
# Usage:
# source gum-catppuccin.sh (inside .bashrc or .zshrc)
# source gum-catppuccin.sh <flavour> <accent> <highlight>
#
# Author: holo96 (Davor Horvacki)
# Github: https://github.com/holo96
#
# Arguments:
# $1 - Catppuccin flavour (latte, frappe, macchiato, mocha) (optional, default: mocha)
# $2 - Accent color: primary color used for selected and cursor elements (optional, default: lavender)
# $3 - Highlight color: secondary color used for headers and emphasis (optional, default: complementary color)
#################################

GUMC_FLAVOUR="${1:-mocha}"

# Validate flavour
if [[ ! "$GUMC_FLAVOUR" =~ ^(latte|frappe|macchiato|mocha)$ ]]; then
  echo "Invalid flavour: $GUMC_FLAVOUR. Must be one of: latte, frappe, macchiato, mocha" >&2
  return 1
fi

GUMC_ACCENT_NAME="${2:-lavender}"
GUMC_HIGHLIGHT_NAME="${3}"
if [[ -z "$GUMC_HIGHLIGHT_NAME" ]]; then
  case $GUMC_ACCENT_NAME in
    rosewater)
      GUMC_HIGHLIGHT_NAME="flamingo"
      ;;
    flamingo)
      GUMC_HIGHLIGHT_NAME="rosewater"
      ;;
    pink)
      GUMC_HIGHLIGHT_NAME="mauve"
      ;;
    mauve)
      GUMC_HIGHLIGHT_NAME="pink"
      ;;
    red)
      GUMC_HIGHLIGHT_NAME="maroon"
      ;;
    maroon)
      GUMC_HIGHLIGHT_NAME="red"
      ;;
    peach)
      GUMC_HIGHLIGHT_NAME="yellow"
      ;;
    yellow)
      GUMC_HIGHLIGHT_NAME="peach"
      ;;
    green)
      GUMC_HIGHLIGHT_NAME="teal"
      ;;
    teal)
      GUMC_HIGHLIGHT_NAME="green"
      ;;
    sky)
      GUMC_HIGHLIGHT_NAME="sapphire"
      ;;
    sapphire)
      GUMC_HIGHLIGHT_NAME="sky"
      ;;
    blue)
      GUMC_HIGHLIGHT_NAME="lavender"
      ;;
    lavender)
      GUMC_HIGHLIGHT_NAME="blue"
      ;;
    *)
      echo "Invalid accent ${GUMC_ACCENT_NAME}" >&2
      return 1
      ;;
  esac
fi

#######################################
# Gets hex value of given color in flavour from Catppuccin theme.
# Globals:
#   None
# Arguments:
#   $1 - flavour (latte, frappe, macchiato, mocha).
#   $2 - color name.
# Outputs:
#   Prints hex color value.
#######################################
function _get_catppuccin_color() {
  case $1 in
    latte)
      case $2 in
        rosewater)
          echo "#dc8a78"
          ;;
        flamingo)
          echo "#dd7878"
          ;;
        pink)
          echo "#ea76cb"
          ;;
        mauve)
          echo "#8839ef"
          ;;
        red)
          echo "#d20f39"
          ;;
        maroon)
          echo "#e64553"
          ;;
        peach)
          echo "#fe640b"
          ;;
        yellow)
          echo "#df8e1d"
          ;;
        green)
          echo "#40a02b"
          ;;
        teal)
          echo "#179299"
          ;;
        sky)
          echo "#04a5e5"
          ;;
        sapphire)
          echo "#209fb5"
          ;;
        blue)
          echo "#1e66f5"
          ;;
        lavender)
          echo "#7287fd"
          ;;
        text)
          echo "#4c4f69"
          ;;
        subtext1)
          echo "#5c5f77"
          ;;
        subtext0)
          echo "#6c6f85"
          ;;
        overlay2)
          echo "#7c7f93"
          ;;
        overlay1)
          echo "#8c8fa1"
          ;;
        overlay0)
          echo "#9ca0b0"
          ;;
        surface2)
          echo "#acb0be"
          ;;
        surface1)
          echo "#bcc0cc"
          ;;
        surface0)
          echo "#ccd0da"
          ;;
        base)
          echo "#eff1f5"
          ;;
        mantle)
          echo "#e6e9ef"
          ;;
        crust)
          echo "#dce0e8"
          ;;
        *)
          echo "Invalid color $2" >&2
          return 1
          ;;
      esac
      ;;
    frappe)
      case $2 in
        rosewater)
          echo "#f2d5cf"
          ;;
        flamingo)
          echo "#eebebe"
          ;;
        pink)
          echo "#f4b8e4"
          ;;
        mauve)
          echo "#ca9ee6"
          ;;
        red)
          echo "#e78284"
          ;;
        maroon)
          echo "#ea999c"
          ;;
        peach)
          echo "#ef9f76"
          ;;
        yellow)
          echo "#e5c890"
          ;;
        green)
          echo "#a6d189"
          ;;
        teal)
          echo "#81c8be"
          ;;
        sky)
          echo "#99d1db"
          ;;
        sapphire)
          echo "#85c1dc"
          ;;
        blue)
          echo "#8caaee"
          ;;
        lavender)
          echo "#babbf1"
          ;;
        text)
          echo "#c6d0f5"
          ;;
        subtext1)
          echo "#b5bfe2"
          ;;
        subtext0)
          echo "#a5adce"
          ;;
        overlay2)
          echo "#949cbb"
          ;;
        overlay1)
          echo "#838ba7"
          ;;
        overlay0)
          echo "#737994"
          ;;
        surface2)
          echo "#626880"
          ;;
        surface1)
          echo "#51576d"
          ;;
        surface0)
          echo "#414559"
          ;;
        base)
          echo "#303446"
          ;;
        mantle)
          echo "#292c3c"
          ;;
        crust)
          echo "#232634"
          ;;
        *)
          echo "Invalid color $2" >&2
          return 1
          ;;
      esac
      ;;
    macchiato)
      case $2 in
        rosewater)
          echo "#f4dbd6"
          ;;
        flamingo)
          echo "#f0c6c6"
          ;;
        pink)
          echo "#f5bde6"
          ;;
        mauve)
          echo "#c6a0f6"
          ;;
        red)
          echo "#ed8796"
          ;;
        maroon)
          echo "#ee99a0"
          ;;
        peach)
          echo "#f5a97f"
          ;;
        yellow)
          echo "#eed49f"
          ;;
        green)
          echo "#a6da95"
          ;;
        teal)
          echo "#8bd5ca"
          ;;
        sky)
          echo "#91d7e3"
          ;;
        sapphire)
          echo "#7dc4e4"
          ;;
        blue)
          echo "#8aadf4"
          ;;
        lavender)
          echo "#b7bdf8"
          ;;
        text)
          echo "#cad3f5"
          ;;
        subtext1)
          echo "#b8c0e0"
          ;;
        subtext0)
          echo "#a5adcb"
          ;;
        overlay2)
          echo "#939ab7"
          ;;
        overlay1)
          echo "#8087a2"
          ;;
        overlay0)
          echo "#6e738d"
          ;;
        surface2)
          echo "#5b6078"
          ;;
        surface1)
          echo "#494d64"
          ;;
        surface0)
          echo "#363a4f"
          ;;
        base)
          echo "#24273a"
          ;;
        mantle)
          echo "#1e2030"
          ;;
        crust)
          echo "#181926"
          ;;
        *)
          echo "Invalid color $2" >&2
          return 1
          ;;
      esac
      ;;
    mocha)
      case $2 in
        rosewater)
          echo "#f5e0dc"
          ;;
        flamingo)
          echo "#f2cdcd"
          ;;
        pink)
          echo "#f5c2e7"
          ;;
        mauve)
          echo "#cba6f7"
          ;;
        red)
          echo "#f38ba8"
          ;;
        maroon)
          echo "#eba0ac"
          ;;
        peach)
          echo "#fab387"
          ;;
        yellow)
          echo "#f9e2af"
          ;;
        green)
          echo "#a6e3a1"
          ;;
        teal)
          echo "#94e2d5"
          ;;
        sky)
          echo "#89dceb"
          ;;
        sapphire)
          echo "#74c7ec"
          ;;
        blue)
          echo "#89b4fa"
          ;;
        lavender)
          echo "#b4befe"
          ;;
        text)
          echo "#cdd6f4"
          ;;
        subtext1)
          echo "#bac2de"
          ;;
        subtext0)
          echo "#a6adc8"
          ;;
        overlay2)
          echo "#9399b2"
          ;;
        overlay1)
          echo "#7f849c"
          ;;
        overlay0)
          echo "#6c7086"
          ;;
        surface2)
          echo "#585b70"
          ;;
        surface1)
          echo "#45475a"
          ;;
        surface0)
          echo "#313244"
          ;;
        base)
          echo "#1e1e2e"
          ;;
        mantle)
          echo "#181825"
          ;;
        crust)
          echo "#11111b"
          ;;
        *)
          echo "Invalid color $2" >&2
          return 1
          ;;
      esac
      ;;
    *)
      echo "Invalid flavour" >&2
      return 1
      ;;
  esac
}

GUMC_ACCENT="$(_get_catppuccin_color "$GUMC_FLAVOUR" "$GUMC_ACCENT_NAME")" || return 1
GUMC_HIGHLIGHT="$(_get_catppuccin_color "$GUMC_FLAVOUR" "$GUMC_HIGHLIGHT_NAME")" || return 1
GUMC_HIGHLIGHTED_BG="$(_get_catppuccin_color "$GUMC_FLAVOUR" surface0)" || return 1
GUMC_DIM="$(_get_catppuccin_color "$GUMC_FLAVOUR" surface1)" || return 1

# choose
export GUM_CHOOSE_CURSOR_FOREGROUND="$GUMC_ACCENT"
export GUM_CHOOSE_SELECTED_FOREGROUND="$GUMC_ACCENT"
export GUM_CHOOSE_HEADER_FOREGROUND="$GUMC_HIGHLIGHT"

# confirm
export GUM_CONFIRM_SELECTED_BACKGROUND="$GUMC_ACCENT"
export GUM_CONFIRM_SELECTED_FOREGROUND="$GUMC_HIGHLIGHTED_BG"
export GUM_CONFIRM_PROMPT_FOREGROUND="$GUMC_HIGHLIGHT"
# shellcheck disable=SC2155
export GUM_CONFIRM_UNSELECTED_FOREGROUND="$(_get_catppuccin_color "$GUMC_FLAVOUR" text)"
export GUM_CONFIRM_UNSELECTED_BACKGROUND="$GUMC_HIGHLIGHTED_BG"

# input
export GUM_INPUT_CURSOR_FOREGROUND="$GUMC_ACCENT"
export GUM_INPUT_HEADER_FOREGROUND="$GUMC_HIGHLIGHT"
export GUM_INPUT_PLACEHOLDER_FOREGROUND="$GUMC_DIM"

# filter
export GUM_FILTER_INDICATOR_FOREGROUND="$GUMC_ACCENT"
export GUM_FILTER_SELECTED_PREFIX_FOREGROUND="$GUMC_ACCENT"
export GUM_FILTER_UNSELECTED_PREFIX_FOREGROUND="$GUMC_DIM"
export GUM_FILTER_HEADER_FOREGROUND="$GUMC_HIGHLIGHT"
export GUM_FILTER_MATCH_FOREGROUND="$GUMC_HIGHLIGHT"
export GUM_FILTER_PROMPT_FOREGROUND="$GUMC_DIM"
export GUM_FILTER_PLACEHOLDER_FOREGROUND="$GUMC_DIM"

# spin
export GUM_SPIN_SPINNER_FOREGROUND="$GUMC_ACCENT"

# table
export GUM_TABLE_SELECTED_FOREGROUND="$GUMC_ACCENT"
export GUM_TABLE_HEADER_FOREGROUND="$GUMC_HIGHLIGHT"

# write
export GUM_WRITE_CURSOR_FOREGROUND="$GUMC_ACCENT"
export GUM_WRITE_HEADER_FOREGROUND="$GUMC_HIGHLIGHT"
export GUM_WRITE_PLACEHOLDER_FOREGROUND="$GUMC_DIM"
export GUM_WRITE_PROMPT_FOREGROUND="$GUMC_HIGHLIGHT"

# file
export GUM_FILE_CURSOR_FOREGROUND="$GUMC_ACCENT"
export GUM_FILE_DIRECTORY_FOREGROUND="$GUMC_HIGHLIGHT"
export GUM_FILE_SELECTED_FOREGROUND="$GUMC_ACCENT"
# shellcheck disable=SC2155
export GUM_FILE_PERMISSIONS_FOREGROUND="$(_get_catppuccin_color "$GUMC_FLAVOUR" subtext1)"
# shellcheck disable=SC2155
export GUM_FILE_FILE_SIZE_FOREGROUND="$(_get_catppuccin_color "$GUMC_FLAVOUR" subtext0)"
# shellcheck disable=SC2155
export GUM_FILE_SYMLINK_FOREGROUND="$(_get_catppuccin_color "$GUMC_FLAVOUR" green)"

# Prevent unnecessary leakage of variables
unset GUMC_ACCENT
unset GUMC_HIGHLIGHT
unset GUMC_HIGHLIGHTED_BG
unset GUMC_DIM
unset GUMC_FLAVOUR
unset _get_catppuccin_color
