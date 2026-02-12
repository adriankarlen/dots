return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    require("catppuccin").setup {
      flavour = "mocha",
      float = {
        solid = true,
      },
      custom_highlights = function(colors)
        return {
          FloatTitle = { fg = colors.peach, bg = colors.mantle, bold = true },
          DiagnosticInfo = { fg = colors.blue },
          DiagnosticHint = { fg = colors.mauve },
          SnacksDashboardSpecial = { fg = colors.surface2, italic = true },
          SnacksDashboardTitle = { fg = colors.text },
          SnacksDashboardDesc = { fg = colors.surface2 },
          SnacksDashboardDir = { fg = colors.surface2, italic = true },
          SnacksDashboardFile = { fg = colors.text },
          SnacksDashboardFooter = { fg = colors.text },
        }
      end,
      integrations = {
        blink_cmp = {
          style = "solid",
        },
        colorful_winsep = {
          color = "red",
        },
        grug_far = true,
        snacks = {
          enabled = true,
          indent_scope_color = "surface2",
        },
        which_key = true,
      },
    }
    -- vim.cmd.colorscheme "catppuccin"
  end,
}
