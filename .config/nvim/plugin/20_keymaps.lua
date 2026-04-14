local nmap = function(lhs, rhs, desc, remap, expr)
  vim.keymap.set("n", lhs, rhs, { desc = desc, remap = remap or false, expr = expr or false })
end
local xmap = function(lhs, rhs, desc, remap)
  vim.keymap.set("x", lhs, rhs, { desc = desc, remap = remap or false })
end

-- Sidekick: NES jump/apply -> inline completion -> fallback <Tab>
nmap("<Tab>", function()
  if require("sidekick").nes_jump_or_apply() then
    return
  end
  if vim.lsp.inline_completion.get() then
    return
  end
  return "<Tab>"
end, "Goto/Apply Next Edit Suggestion", false, true)

-- Paste linewise before/after current line
-- Usage: `yiw` to yank a word and `]p` to put it on the next line.
nmap("[p", '<Cmd>exe "iput! " . v:register<CR>', "Paste Above")
nmap("]p", '<Cmd>exe "iput "  . v:register<CR>', "Paste Below")

-- Clear search highlight
nmap("<Esc>", "<Cmd>noh<CR>", "Clear search highlight")

-- Tmux navigation
nmap("<C-h>", "<Cmd>TmuxNavigateLeft<CR>", "Navigate left")
nmap("<C-j>", "<Cmd>TmuxNavigateDown<CR>", "Navigate down")
nmap("<C-k>", "<Cmd>TmuxNavigateUp<CR>", "Navigate up")
nmap("<C-l>", "<Cmd>TmuxNavigateRight<CR>", "Navigate right")
nmap("<C-\\>", "<Cmd>TmuxNavigatePrevious<CR>", "Navigate previous")

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

nmap_leader("ba", "<Cmd>b#<CR>", "Alternate")
nmap_leader("bd", "<Cmd>lua MiniBufremove.delete()<CR>", "Delete")
nmap_leader("bD", "<Cmd>lua MiniBufremove.delete(0, true)<CR>", "Delete!")
nmap_leader("bs", new_scratch_buffer, "Scratch")
nmap_leader("bw", "<Cmd>lua MiniBufremove.wipeout()<CR>", "Wipeout")
nmap_leader("bW", "<Cmd>lua MiniBufremove.wipeout(0, true)<CR>", "Wipeout!")

-- e is for 'Explore'
local explore_quickfix = function()
  vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and "cclose" or "copen")
end
local explore_locations = function()
  vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and "lclose" or "lopen")
end

nmap_leader("ef", '<Cmd>lua require("oil").toggle_float()<CR>', "File explorer")
nmap_leader("en", "<Cmd>lua MiniNotify.show_history()<CR>", "Notifications")
nmap_leader("eq", explore_quickfix, "Quickfix list")
nmap_leader("eQ", explore_locations, "Location list")

-- f is for 'Find'
nmap_leader("fb", "<Cmd>lua Snacks.picker.buffers()<CR>", "buffers")
nmap_leader("ff", "<Cmd>lua Snacks.picker.files { hidden = true }<CR>", "files")
nmap_leader("fF", "<Cmd>lua Snacks.picker.files { hidden = true, ignored = true }<CR>", "files (including ignored)")
nmap_leader("fw", "<Cmd>lua Snacks.picker.grep { hidden = true }<CR>", "live grep")
nmap_leader("fi", "<Cmd>lua Snacks.picker.icons()<CR>", "icons")
nmap_leader("fc", "<Cmd>lua Snacks.picker.grep { pattern = vim.fn.expand('<cword>') }<CR>", "grep word under cursor")

xmap_leader("fw", "<Cmd>lua Snacks.picker.grep_word()<CR>", "grep selection")

-- g is for 'Git'
nmap_leader("gd", "<Cmd>lua MiniDiff.toggle_overlay()<CR>", "toggle overlay")
nmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at cursor")

xmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at selection")

-- l is for 'Language'
nmap_leader("la", "<Cmd>lua vim.lsp.buf.code_action()<CR>", "Actions")
nmap_leader("ld", "<Cmd>lua vim.diagnostic.open_float()<CR>", "Diagnostic popup")
nmap_leader("lf", "<Cmd>lua require('conform').format()<CR>", "format")
nmap_leader("li", "<Cmd>lua vim.lsp.buf.implementation()<CR>", "Implementation")
nmap_leader("lh", "<Cmd>lua vim.lsp.buf.hover()<CR>", "Hover")
nmap_leader("ll", "<Cmd>lua vim.lsp.codelens.run()<CR>", "Lens")
nmap_leader("lr", "<Cmd>lua vim.lsp.buf.rename()<CR>", "Rename")
nmap_leader("lR", "<Cmd>lua vim.lsp.buf.references()<CR>", "References")
nmap_leader("ls", "<Cmd>lua vim.lsp.buf.definition()<CR>", "Source definition")
nmap_leader("lt", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", "Type definition")
nmap_leader("lc", "<Cmd>TSC<CR>", "Typecheck project")

xmap_leader("lf", '<Cmd>lua require("conform").format()<CR>', "Format selection")

-- m is for 'Map'
nmap_leader("mf", "<Cmd>lua MiniMap.toggle_focus()<CR>", "Focus (toggle)")
nmap_leader("mr", "<Cmd>lua MiniMap.refresh()<CR>", "Refresh")
nmap_leader("mt", "<Cmd>lua MiniMap.toggle()<CR>", "Toggle")

-- o is for 'Other'
nmap_leader("or", "<Cmd>lua MiniMisc.resize_window()<CR>", "Resize to default width")
nmap_leader("ot", "<Cmd>lua MiniTrailspace.trim()<CR>", "Trim trailspace")
nmap_leader("oz", "<Cmd>lua MiniMisc.zoom()<CR>", "Zoom toggle")
nmap_leader("op", '"+p<CR>', "Paste from system clipboard")
nmap_leader("oy", '"+y<CR>', "Yank to system clipboard")

xmap_leader("op", '"+p<CR>', "Paste from system clipboard")
xmap_leader("oy", '"+y<CR>', "Yank to system clipboard")

-- s is for 'Session'
local session_new = 'vim.ui.input({ prompt = "Session name: " }, MiniSessions.write)'
nmap_leader("sd", '<Cmd>lua MiniSessions.select("delete")<CR>', "Delete")
nmap_leader("sn", "<Cmd>lua " .. session_new .. "<CR>", "New")
nmap_leader("sr", '<Cmd>lua MiniSessions.select("read")<CR>', "Read")
nmap_leader("sR", "<Cmd>lua MiniSessions.restart()<CR>", "Restart")
nmap_leader("sw", "<Cmd>lua MiniSessions.write()<CR>", "Write current")
