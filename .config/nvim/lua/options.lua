local opt = vim.opt
local o = vim.o
local g = vim.g

-- ─[ globals ]────────────────────────────────────────────────────────
g.mapleader = " "
g.maplocalleader = ","

-- ─[ options ]────────────────────────────────────────────────────────
opt.clipboard = "unnamedplus"
opt.cursorline = true
opt.laststatus = 2
opt.showmode = false
o.winborder = "solid"
require("vim._extui").enable {}
o.cmdheight = 0

-- split
opt.splitkeep = "screen"

-- indenting
opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true
opt.tabstop = 2
opt.softtabstop = 2

opt.fillchars = { eob = " " }
opt.ignorecase = true
opt.smartcase = true
opt.mouse = "a"

-- numbers
o.number = true
o.numberwidth = 2
o.ruler = false
o.rnu = true

-- disable nvim intro
opt.shortmess:append "sI"
opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.timeoutlen = 400
opt.undofile = true

-- diagnostic configurations
vim.diagnostic.config {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
  virtual_text = false,
}

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append "<>[]hl"

-- disable some default providers
for _, provider in ipairs { "node", "perl", "python3", "ruby" } do
  g["loaded_" .. provider .. "_provider"] = 0
end

-- add filetype handlings
vim.filetype.add {
  extension = {
    mdx = "mdx",
    xaml = "xml",
  },
  pattern = {
    ["*.user.css"] = "less",
    [".*%.conf"] = "nginx",
  },
}
