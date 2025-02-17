-- ─[ mappings ]───────────────────────────────────────────────────────
local map = vim.keymap
local api = vim.api
local ui = vim.ui
local cmd = vim.cmd
local fn = vim.fn

-- go to beginning and end
map.set("i", "<C-6>", "<esc>^i", { desc = "go to beginning of line" })
map.set("i", "<C-4>", "<end>", { desc = "go to end of line" })

map.set("n", "<esc>", "<cmd> noh <cr>", { silent = true, desc = "clear search highlight" })

-- switch between windows
map.set("n", "<C-h>", "<C-w>h", { desc = "move to left window" })
map.set("n", "<C-j>", "<C-w>j", { desc = "move to lower window" })
map.set("n", "<C-k>", "<C-w>k", { desc = "move to upper window" })
map.set("n", "<C-l>", "<C-w>l", { desc = "move to right window" })

-- save
map.set("n", "<C-s>", "<cmd> w <cr>", { desc = "save current file" })

-- copy all
map.set("n", "<C-c>", "<cmd> %y+ <cr>", { desc = "copy all to clipboard" })

-- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
map.set(
  { "n", "v" },
  "j",
  'v:count || mode(1)[0:1] == "no" ? "j" : "gj"',
  { expr = true, desc = "move down through wrapped lines" }
)
map.set(
  { "n", "v" },
  "k",
  'v:count || mode(1)[0:1] == "no" ? "k" : "gk"',
  { expr = true, desc = "move up through wrapped lines" }
)
map.set(
  { "n", "v" },
  "<up>",
  'v:count || mode(1)[0:1] == "no" ? "k" : "gk"',
  { expr = true, desc = "move up through wrapped lines" }
)
map.set(
  { "n", "v" },
  "<down>",
  'v:count || mode(1)[0:1] == "no" ? "j" : "gj"',
  { expr = true, desc = "move down through wrapped lines" }
)

-- buffer management
map.set("n", "<leader>bn", "<cmd> enew <cr>", { desc = "new buffer" })
map.set("n", "<leader>bd", "<cmd> bd <cr>", { desc = "delete current buffer" })
map.set("n", "<leader>bD", "<cmd> %bd|e#|bd#|'\" <cr>", { desc = "delete all buffers except current one" })

-- paste without copying
map.set("x", "p", 'p:let @+=@0<cr>:let @"=@0<cr>', { desc = "paste without copying" })

-- simpler movement on nordic keyboards
map.set("n", ";", ":", { desc = "replace semicolon with colon", remap = true })
map.set( "n" , "å", "\\", { desc = "replace å with backslash", remap = true })
map.set( "n" , "ö", "[", { desc = "replace ö with left bracket", remap = true })
map.set( "n" , "ä", "]", { desc = "replace ä with right bracket", remap = true })
map.set({ "n", "x" }, "*", '"', { desc = "replace * with double quote", remap = true })
map.set({ "n", "x" }, "Ö", "{", { desc = "replace Ö with left curly brace", remap = true })
map.set({ "n", "x" }, "Ä", "}", { desc = "replace Ä with right curly brace", remap = true })
map.set({ "n", "s", "x" }, "&", "^", { desc = "replace & with caret", remap = true })
map.set({ "n", "s", "x" }, "€", "$", { desc = "replace € with dollar sign", remap = true })

-- capitalize word in insert mode
map.set("i", "GG", "<esc>bgUiwea", { desc = "make word uppercase" })

-- select buffer
map.set("n", "<leader><tab>", function()
  local buffers = vim.tbl_filter(function(bufnr)
    return fn.buflisted(bufnr) == 1 and bufnr ~= api.nvim_get_current_buf()
  end, api.nvim_list_bufs())
  local named = vim.tbl_map(function(bufnr)
    local path = fn.bufname(bufnr)
    return fn.fnamemodify(path, ":~:.:h") .. "/" .. fn.fnamemodify(path, ":t")
  end, buffers)
  ui.select(named, { prompt = "select buffer" }, function(selection)
    vim.cmd.edit(selection)
  end)
end, { desc = "buffers" })
