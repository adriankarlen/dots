local add = vim.pack.add
local now = Config.now

now(function()
  add { { src = "https://github.com/rose-pine/neovim", name = "rose-pine" } }
  ---@diagnostic disable-next-line: missing-fields, param-type-mismatch
  require("rose-pine").setup {
    highlight_groups = {
      MatchParen = { fg = "love", bg = "love", blend = 25 },
      MiniStarterHeader = { fg = "love" },
    },
  }
  vim.cmd.colorscheme "rose-pine"
end)
