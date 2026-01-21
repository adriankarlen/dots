return {
  "AlexvZyl/nordic.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("nordic").setup {
      after_palette = function(c)
        c.hint = c.magenta.base
      end,
    }
    require("nordic").load()
  end,
}
