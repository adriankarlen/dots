local nmap = function(lhs, rhs, desc, remap, expr)
  vim.keymap.set("n", lhs, rhs, { desc = desc, remap = remap or false, expr = expr or false })
end
local xmap = function(lhs, rhs, desc, remap)
  vim.keymap.set("x", lhs, rhs, { desc = desc, remap = remap or false })
end

-- Copy selection to system clipboard
xmap("Y", '"+y', "yank to system clipboard")
-- Copy entire file contents to system clipboard
nmap("yY", function()
  local winview = vim.fn.winsaveview()
  vim.cmd 'keepjumps keepmarks normal! ggVG"+y'
  vim.fn.winrestview(winview)
end, "yank entire file to system clipboard")

-- Paste linewise before/after current line
nmap("[p", '<Cmd>exe "iput! " . v:register<CR>', "paste above")
nmap("]p", '<Cmd>exe "iput "  . v:register<CR>', "paste below")

-- Clear search highlight
nmap("<Esc>", "<Cmd>noh<CR>", "clear search highlight")

-- Tmux navigation
nmap("<C-h>", "<Cmd>TmuxNavigateLeft<CR>", "navigate left")
nmap("<C-j>", "<Cmd>TmuxNavigateDown<CR>", "navigate down")
nmap("<C-k>", "<Cmd>TmuxNavigateUp<CR>", "navigate up")
nmap("<C-l>", "<Cmd>TmuxNavigateRight<CR>", "navigate right")
nmap("<C-\\>", "<Cmd>TmuxNavigatePrevious<CR>", "navigate previous")

-- Nordic keyboard remaps
-- å -> \ : leader for marks, e.g. åma to set mark a
nmap("å", "\\", "å -> \\", true)
-- ö -> [ : previous motions, e.g. öd for prev diagnostic, öp for paste above
nmap("ö", "[", "ö -> [", true)
-- ä -> ] : next motions, e.g. äd for next diagnostic, äp for paste below
nmap("ä", "]", "ä -> ]", true)
-- Ö -> { : jump to previous blank line / paragraph
nmap("Ö", "{", "Ö -> {", true)
xmap("Ö", "{", "Ö -> {", true)
-- Ä -> } : jump to next blank line / paragraph
nmap("Ä", "}", "Ä -> }", true)
xmap("Ä", "}", "Ä -> }", true)
-- & -> ^ : first non-blank character of line
nmap("&", "^", "& -> ^", true)
xmap("&", "^", "& -> ^", true)
-- € -> $ : end of line
nmap("€", "$", "€ -> $", true)
xmap("€", "$", "€ -> $", true)

Config.leader_group_clues = {
  { mode = "n", keys = "<Leader>a", desc = "+ai" },
  { mode = "n", keys = "<Leader>b", desc = "+buffer" },
  { mode = "n", keys = "<Leader>e", desc = "+explore" },
  { mode = "n", keys = "<Leader>f", desc = "+find" },
  { mode = "n", keys = "<Leader>g", desc = "+git" },
  { mode = "n", keys = "<Leader>l", desc = "+language" },
  { mode = "n", keys = "<Leader>m", desc = "+map" },
  { mode = "n", keys = "<Leader>o", desc = "+other" },
  { mode = "n", keys = "<Leader>s", desc = "+session" },

  { mode = "x", keys = "<Leader>a", desc = "+ai" },
  { mode = "x", keys = "<Leader>g", desc = "+git" },
  { mode = "x", keys = "<Leader>l", desc = "+language" },
}

-- Helpers for a more concise `<Leader>` mappings
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end
local xmap_leader = function(suffix, rhs, desc)
  vim.keymap.set("x", "<Leader>" .. suffix, rhs, { desc = desc })
end

-- a is for 'AI'
nmap_leader("aa", "<Cmd>lua require('sidekick.cli').toggle { focus = true }<CR>", "toggle")
nmap_leader("ao", "<Cmd>lua require('sidekick.cli').toggle { name = 'opencode', focus = true }<CR>", "toggle opencode")
nmap_leader("ap", "<Cmd>lua require('sidekick.cli').prompt()<CR>", "ask prompt")

xmap_leader("ap", "<Cmd>lua require('sidekick.cli').prompt()<CR>", "ask prompt")

-- b is for 'Buffer'
local new_scratch_buffer = function()
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end

nmap_leader("ba", "<Cmd>b#<CR>", "alternate")
nmap_leader("bd", "<Cmd>lua MiniBufremove.delete()<CR>", "delete")
nmap_leader("bD", "<Cmd>lua MiniBufremove.delete(0, true)<CR>", "delete!")
nmap_leader("bs", new_scratch_buffer, "scratch")
nmap_leader("bw", "<Cmd>lua MiniBufremove.wipeout()<CR>", "wipeout")
nmap_leader("bW", "<Cmd>lua MiniBufremove.wipeout(0, true)<CR>", "wipeout!")
nmap_leader("bq", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current then
      MiniBufremove.delete(buf)
    end
  end
end, "delete others")

-- e is for 'Explore'
local explore_at_file = "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>"
local explore_quickfix = function()
  vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and "cclose" or "copen")
end
local explore_locations = function()
  vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and "lclose" or "lopen")
end

nmap_leader("ed", "<Cmd>lua MiniFiles.open()<CR>", "directory")
nmap_leader("ef", explore_at_file, "file directory")
nmap_leader("en", "<Cmd>lua MiniNotify.show_history()<CR>", "notifications")
nmap_leader("eq", explore_quickfix, "quickfix list")
nmap_leader("eQ", explore_locations, "location list")

-- f is for 'Find'
nmap_leader("fb", "<Cmd>Pick buffers<CR>", "buffers")
nmap_leader("fc", "<Cmd>Pick git_commits<CR>", "commits (all)")
nmap_leader("fC", '<Cmd>Pick git_commits path="%"<CR>', "commits (buf)")
nmap_leader("fd", '<Cmd>Pick diagnostic scope="all"<CR>', "diagnostic workspace")
nmap_leader("fD", '<Cmd>Pick diagnostic scope="current"<CR>', "diagnostic buffer")
nmap_leader("ff", "<Cmd>Pick git_files<CR>", "files")
nmap_leader("fh", "<Cmd>Pick help<CR>", "Help tags")
nmap_leader("fw", "<Cmd>Pick grep_live<CR>", "grep live")
nmap_leader("fc", "<Cmd>Pick grep pattern='<cword>'<CR>", "grep current word")

-- g is for 'Git'
nmap_leader("gd", "<Cmd>lua MiniDiff.toggle_overlay()<CR>", "toggle overlay")
nmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "show at cursor")

xmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "show at selection")

-- l is for 'Language'
nmap_leader("la", "<Cmd>lua vim.lsp.buf.code_action()<CR>", "actions")
nmap_leader("ld", "<Cmd>lua vim.diagnostic.open_float()<CR>", "diagnostic popup")
nmap_leader("lf", "<Cmd>lua require('conform').format()<CR>", "format")
nmap_leader("li", "<Cmd>lua vim.lsp.buf.implementation()<CR>", "implementation")
nmap_leader("lh", "<Cmd>lua vim.lsp.buf.hover()<CR>", "hover")
nmap_leader("ll", "<Cmd>lua vim.lsp.codelens.run()<CR>", "lens")
nmap_leader("lr", "<Cmd>lua vim.lsp.buf.rename()<CR>", "rename")
nmap_leader("lR", "<Cmd>lua vim.lsp.buf.references()<CR>", "references")
nmap_leader("ls", "<Cmd>lua vim.lsp.buf.definition()<CR>", "source definition")
nmap_leader("lt", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", "type definition")
nmap_leader("lc", "<Cmd>TSC<CR>", "typecheck project")

xmap_leader("lf", '<Cmd>lua require("conform").format()<CR>', "format selection")

-- m is for 'Map'
nmap_leader("mf", "<Cmd>lua MiniMap.toggle_focus()<CR>", "focus (toggle)")
nmap_leader("mr", "<Cmd>lua MiniMap.refresh()<CR>", "refresh")
nmap_leader("mt", "<Cmd>lua MiniMap.toggle()<CR>", "toggle")

-- o is for 'Other'
nmap_leader("or", "<Cmd>lua MiniMisc.resize_window()<CR>", "resize to default width")
nmap_leader("ot", "<Cmd>lua MiniTrailspace.trim()<CR>", "trim trailspace")
nmap_leader("oz", "<Cmd>lua MiniMisc.zoom()<CR>", "zoom toggle")
nmap_leader("op", '"+p<CR>', "paste from system clipboard")

xmap_leader("op", '"+p<CR>', "paste from system clipboard")

-- s is for 'Session'
local session_new = 'vim.ui.input({ prompt = "Session name: " }, MiniSessions.write)'
nmap_leader("sd", '<Cmd>lua MiniSessions.select("delete")<CR>', "delete")
nmap_leader("sn", "<Cmd>lua " .. session_new .. "<CR>", "new")
nmap_leader("sr", '<Cmd>lua MiniSessions.select("read")<CR>', "read")
nmap_leader("sR", "<Cmd>lua MiniSessions.restart()<CR>", "restart")
nmap_leader("sw", "<Cmd>lua MiniSessions.write()<CR>", "write current")
