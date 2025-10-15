local M = {}
local state = {
  cache = {
    diagnostics = "",
    last_update = 0,
  },
}

---@param n integer
---@return string
local function _spacer(n)
  return string.rep(" ", n)
end

local function _align()
  return "%="
end

-- From TJDevries
-- https://github.com/tjdevries/lazy-require.nvim
local function lazy_require(require_path)
  return setmetatable({}, {
    __index = function(_, key)
      return require(require_path)[key]
    end,

    __newindex = function(_, key, value)
      require(require_path)[key] = value
    end,
  })
end

local is_truncated = function(trunc_width)
  local cur_width = vim.o.laststatus == 3 and vim.o.columns or vim.api.nvim_win_get_width(0)
  return cur_width < (trunc_width or -1)
end

local CTRL_S = vim.api.nvim_replace_termcodes("<C-S>", true, true, true)
local CTRL_V = vim.api.nvim_replace_termcodes("<C-V>", true, true, true)

local modes = setmetatable({
  ["n"] = { long = "NORMAL", short = "N", hl = "StatuslineModeNormal" },
  ["v"] = { long = "VISUAL", short = "V", hl = "StatuslineModeVisual" },
  ["V"] = { long = "V-LINE", short = "V-L", hl = "StatuslineModeVisual" },
  [CTRL_V] = { long = "V-BLOCK", short = "V-B", hl = "StatuslineModeVisual" },
  ["s"] = { long = "SELECT", short = "S", hl = "StatuslineModeVisual" },
  ["S"] = { long = "S-LINE", short = "S-L", hl = "StatuslineModeVisual" },
  [CTRL_S] = { long = "S-BLOCK", short = "S-B", hl = "StatuslineModeVisual" },
  ["i"] = { long = "INSERT", short = "I", hl = "StatuslineModeInsert" },
  ["R"] = { long = "REPLACE", short = "R", hl = "StatuslineModeReplace" },
  ["c"] = { long = "COMMAND", short = "C", hl = "StatuslineModeCommand" },
  ["r"] = { long = "PROMPT", short = "P", hl = "StatuslineModeOther" },
  ["!"] = { long = "SHELL", short = "Sh", hl = "StatuslineModeOther" },
  ["t"] = { long = "TERMINAL", short = "T", hl = "StatuslineModeOther" },
}, {
  __index = function()
    return { long = "Unknown", short = "U", hl = "StatuslineModeOther" }
  end,
})

local function get_mode()
  local mode_info = modes[vim.fn.mode()]
  local mode = is_truncated(120) and mode_info.short or mode_info.long
  return tools.hl_str(mode_info.hl, _spacer(1) .. mode .. _spacer(1))
end

local function get_path()
  if vim.fn.mode() == "t" then
    return ""
  end
  if is_truncated(100) then
    return _spacer(1)
  end
  local path = vim.fn.expand "%:~:.:h"
  local max_width = 30
  if path == "." or path == "" then
    return ""
  elseif #path > max_width then
    path = "…" .. string.sub(path, -max_width + 2)
  end
  return tools.hl_str("StatuslineFilepath", path .. _spacer(1))
end

local function get_filename()
  if vim.fn.mode() == "t" then
    return ""
  end
  local filename = vim.fn.expand "%:~:t"
  local buf = vim.api.nvim_get_current_buf()
  local icon, icon_hl, _ = require("mini.icons").get("filetype", vim.bo.filetype)
  local diagnostic_map = {
    [vim.diagnostic.severity.ERROR] = "DiagnosticError",
    [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
    [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
    [vim.diagnostic.severity.HINT] = "DiagnosticHint",
  }
  local diagnostics = vim.diagnostic.get(buf)
  local hl = #diagnostics > 0 and diagnostic_map[diagnostics[1].severity] or "StatuslineTextMain"

  if filename == "" then
    return tools.hl_str(hl, "[No Name]")
  end
  return tools.hl_str(icon_hl, icon .. _spacer(1)) .. tools.hl_str(hl, filename .. _spacer(1))
end

local function get_modification_status()
  local buf_modified = vim.bo.modified
  local buf_modifiable = vim.bo.modifiable
  local buf_readonly = vim.bo.readonly
  if buf_modified then
    return tools.hl_str("DiagnosticWarn", "●" .. _spacer(2))
  elseif buf_modifiable == false or buf_readonly == true then
    return tools.hl_str("DiagnosticError", "󰑇" .. _spacer(2))
  else
    return _spacer(2) -- No modification status
  end
end

local function get_lsp_status()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  if #clients > 0 and clients[1].initialized then
    return tools.hl_str("DiagnosticWarn", " " .. _spacer(1))
  else
    return ""
  end
end

local function get_formatter_status()
  local conform = lazy_require "conform"

  local formatters = conform.list_formatters(0)
  if #formatters > 0 then
    return tools.hl_str("Special", " " .. _spacer(1))
  else
    return ""
  end
end

local function get_copilot_status()
  local status = require("sidekick.status").get()
  if not status then
    return ""
  end
  local hl = status.kind == "Error" and "DiagnosticError" or status.busy and "DiagnosticWarn" or "Define"
  return tools.hl_str(hl, " " .. _spacer(1))
end

local function get_diagnostics()
  if state.cache.diagnostics and vim.uv.now() - state.cache.last_update < 100 then
    return state.cache.diagnostics
  end
  local severities = {
    { name = "E", hl = "DiagnosticError" },
    { name = "W", hl = "DiagnosticWarn" },
    { name = "I", hl = "DiagnosticInfo" },
    { name = "H", hl = "DiagnosticHint" },
  }

  local result = ""
  local diag_count = 0

  for _, severity in ipairs(severities) do
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[severity.name] })
    if count > 0 then
      result = result .. tools.hl_str(severity.hl, " " .. count .. _spacer(1))
      diag_count = 1
    end
  end

  local ret = result .. _spacer(diag_count)
  state.cache.diagnostics = ret
  return ret
end

local function get_dotnet_solution()
  local solution = vim.fs.basename(vim.g.roslyn_nvim_selected_solution)
  if solution == nil then
    return ""
  end
  solution = solution:gsub("%.[^%.]+$", "")
  local icon, hl, _ = require("mini.icons").get("filetype", "solution")
  return tools.hl_str(hl, icon .. " ") .. tools.hl_str("StatuslineTextMain", solution .. _spacer(2))
end

local function get_recording()
  local recording = vim.fn.reg_recording()
  if recording == "" then
    return ""
  end
  return tools.hl_str("StatuslineTextAccent", "󰑋 ")
    .. tools.hl_str("DiagnosticError", recording .. " recording" .. _spacer(2))
end

local function get_branch()
  if is_truncated(40) then
    return ""
  end
  local branch = vim.b.minigit_summary_string or ""
  if branch == "" then
    return ""
  end
  return tools.hl_str("StatuslineTextAccent", " ") .. tools.hl_str("StatuslineTextMain", branch .. _spacer(2))
end

local function get_scrollbar()
  if is_truncated(75) then
    return ""
  end

  local sbar_chars = { "▔", "🮂", "🬂", "🮃", "▀", "▄", "▃", "🬭", "▂", "▁" }

  local cur_line = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_line_count(0)

  local i = math.floor((cur_line - 1) / lines * #sbar_chars) + 1
  local sbar = string.rep(sbar_chars[i], 2)

  return tools.hl_str("DiagnosticError", sbar .. _spacer(1))
end

M.setup = function()
  vim.opt.laststatus = 3
  vim.opt.showmode = false
end

M.load = function()
  local curr_ft = vim.bo.filetype
  local disabled_filetypes = {
    "dashboard",
  }

  if vim.tbl_contains(disabled_filetypes, curr_ft) then
    return nil
  end

  return table.concat {
    get_mode(),
    get_path(),
    get_filename(),
    get_modification_status(),
    get_lsp_status(),
    get_formatter_status(),
    get_copilot_status(),
    get_diagnostics(),
    _align(),
    get_recording(),
    _align(),
    get_dotnet_solution(),
    get_branch(),
    get_scrollbar(),
  }
end

vim.api.nvim_create_augroup("Statusline", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = "Statusline",
  pattern = "*",
  callback = function()
    vim.o.statusline = "%!v:lua.require'statusline'.load()"
  end,
})

return M
