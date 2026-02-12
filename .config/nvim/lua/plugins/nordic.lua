return {
  "AlexvZyl/nordic.nvim",
  lazy = false,
  priority = 1000,
  envbled = false,
  config = function()
    require("nordic").setup {
      after_palette = function(c)
        c.hint = c.orange.bright
      end,
      on_highlight = function(hl, c)
        hl.CursorLineNr = { fg = c.orange.bright, bold = true }
        vim.api.nvim_set_hl(0, "ColorfulWinSep", { fg = c.orange.base })
        vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = c.comment })
        vim.api.nvim_set_hl(0, "SnacksDashboardSpecial", { fg = c.comment, italic = true })
        vim.api.nvim_set_hl(0, "SnacksDashboardDir", { fg = c.comment, italic = true })
        vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { fg = c.comment })
        vim.api.nvim_set_hl(0, "SnacksDashboardFooter", { fg = c.white0 })
        vim.api.nvim_set_hl(0, "SnacksDashboardTitle", { fg = c.white0 })
        vim.api.nvim_set_hl(0, "SnacksDashboardFile", { fg = c.white0 })
      end,
    }
    -- require("nordic").load()
  end,
}
