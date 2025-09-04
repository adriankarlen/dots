return {
  {
    "dmmulroy/ts-error-translator.nvim",
    event = "LspAttach",
    opts = {},
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    opts = {
      preset = "simple",
      signs = {
        diag = "",
      },
      hi = {
        mixing_color = "#191724",
      },
      blend = {
        factor = 0.15,
      },
    },
  },
}
