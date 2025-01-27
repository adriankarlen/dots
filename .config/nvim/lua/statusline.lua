local M = {}

local function _spacer(n)
  local spaces = string.rep(" ", n)
  return "%#StatuslineTextMain#" .. spaces
end

local function _align()
  return "%="
end

local function _truncate()
  return "%<"
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
  ["n"] = { long = "NORMAL", short = "N", hl = "%#StatuslineModeNormal#" },
  ["v"] = { long = "VISUAL", short = "V", hl = "%#StatuslineModeVisual#" },
  ["V"] = { long = "V-LINE", short = "V-L", hl = "%#StatuslineModeVisual#" },
  [CTRL_V] = { long = "V-BLOCK", short = "V-B", hl = "%#StatuslineModeVisual#" },
  ["s"] = { long = "SELECT", short = "S", hl = "%#StatuslineModeVisual#" },
  ["S"] = { long = "S-LINE", short = "S-L", hl = "%#StatuslineModeVisual#" },
  [CTRL_S] = { long = "S-BLOCK", short = "S-B", hl = "%#StatuslineModeVisual#" },
  ["i"] = { long = "INSERT", short = "I", hl = "%#StatuslineModeInsert#" },
  ["R"] = { long = "REPLACE", short = "R", hl = "%#StatuslineModeReplace#" },
  ["c"] = { long = "COMMAND", short = "C", hl = "%#StatuslineModeCommand#" },
  ["r"] = { long = "PROMPT", short = "P", hl = "%#StatuslineModeOther#" },
  ["!"] = { long = "SHELL", short = "Sh", hl = "%#StatuslineModeOther#" },
  ["t"] = { long = "TERMINAL", short = "T", hl = "%#StatuslineModeOther#" },
}, {
  __index = function()
    return { long = "Unknown", short = "U", hl = "%#StatuslineModeOther#" }
  end,
})

local function get_mode()
  local mode_info = modes[vim.fn.mode()]
  local mode = is_truncated(120) and mode_info.short or mode_info.long
  return mode_info.hl .. " " .. mode .. " " .. _spacer(1)
end

local function get_filetype()
  local disabled_modes = {
    "t",
    "!",
  }
  if vim.tbl_contains(disabled_modes, vim.fn.mode()) then
    return ""
  end
  local icon, hl, _ = require("mini.icons").get("filetype", vim.bo.filetype)
  hl = "%#" .. hl .. "#"
  return hl .. icon .. _spacer(1)
end

local function get_path()
  if vim.fn.mode() == "t" then
    return ""
  end
  if is_truncated(100) then
    return _spacer(1)
  end
  local path = vim.fn.expand "%:~:.:h"
  local hl = "%#StatuslineTextAccent#"
  local max_width = 30
  if path == "." or path == "" then
    return ""
  elseif #path > max_width then
    path = "…" .. string.sub(path, -max_width + 2)
  end
  return hl .. path .. "/"
end

local function get_filename()
  if vim.fn.mode() == "t" then
    return ""
  end
  local filename = vim.fn.expand "%:~:t"
  local path = vim.fn.expand "%:~:.:h"
  local hl = "%#StatuslineTextMain#"
  if filename == "" then
    return hl .. "[No Name]" .. _spacer(1)
  end
  if path == "." then
    return hl .. filename .. _spacer(1)
  end
  return hl .. filename .. _spacer(1)
end

local function get_modification_status()
  local buf_modified = vim.bo.modified
  local buf_modifiable = vim.bo.modifiable
  local buf_readonly = vim.bo.readonly
  local hi_notsaved = "%#StatuslineNotSaved#"
  local hi_readonly = "%#StatuslineReadOnly#"
  if buf_modified then
    return hi_notsaved .. "•" .. _spacer(1)
  elseif buf_modifiable == false or buf_readonly == true then
    return hi_readonly .. "󰑇" .. _spacer(1)
  else
    return ""
  end
end

local function get_lsp_status()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  local hl = "%#StatuslineLspOn#"
  if #clients > 0 and clients[1].initialized then
    return hl .. " " .. _spacer(1)
  else
    return ""
  end
end

local function get_formatter_status()
  local hl = "%#StatuslineFormatterStatus#"
  local conform = lazy_require "conform"

  local formatters = conform.list_formatters(0)
  if #formatters > 0 then
    return hl .. " " .. _spacer(1)
  else
    return ""
  end
end

local function get_copilot_status()
  local hl_copilot = "%#StatuslineCopilot#"
  local c = lazy_require "copilot.client"
  local ok = not c.is_disabled() and c.buf_is_attached(vim.api.nvim_get_current_buf())
  if not ok then
    return ""
  end
  return hl_copilot .. " " .. _spacer(1)
end

local function get_arrow_status()
  local hl_main = "%#StatuslineTextMain#"
  local hl_accent = "%#StatuslineTextAccent#"
  local arrow = lazy_require "arrow.statusline"
  if not arrow.is_on_arrow_file() then
    return ""
  end
  local index = arrow.text_for_statusline()
  return hl_accent .. "󱡁 " .. hl_main .. index .. _spacer(1)
end

local function get_diagnostics()
  local count_error = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local count_warning = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local count_info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  local count_hint = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
  local diag_count = 0
  local hl_error = "%#DiagnosticError#"
  local hl_warning = "%#DiagnosticWarn#"

  local hl_info = "%#DiagnosticInfo#"
  local hl_hint = "%#DiagnosticHint#"
  local error, warning, info, hint = "", "", "", ""
  if count_error == 0 then
    error = ""
  else
    error = hl_error .. "• " .. count_error .. _spacer(1)
  end
  if count_warning == 0 then
    warning = ""
  else
    warning = hl_warning .. "• " .. count_warning .. _spacer(1)
  end
  if count_info == 0 then
    info = ""
  else
    info = hl_info .. "• " .. count_info .. _spacer(1)
  end
  if count_hint == 0 then
    hint = ""
  else
    hint = hl_hint .. "• " .. count_hint .. _spacer(1)
  end
  if count_error + count_warning + count_info + count_hint == 0 then
    diag_count = 0
  else
    diag_count = 1
  end
  return error .. warning .. info .. hint .. _spacer(diag_count)
end

local function get_dotnet_solution()
  local hl_main = "%#StatuslineTextMain#"
  local solution = vim.fs.basename(vim.g.roslyn_nvim_selected_solution)
  if solution == nil then
    return ""
  end
  solution = solution:gsub("%.[^%.]+$", "")
  local icon, hl, _ = require("mini.icons").get("filetype", "solution")
  hl = "%#" .. hl .. "#"
  return hl .. icon .. " " .. hl_main .. solution .. _spacer(2)
end

local function get_branch()
  if is_truncated(40) then
    return ""
  end
  local branch = vim.b.minigit_summary_string or ""
  local hl_main = "%#StatuslineTextMain#"
  local hl_accent = "%#StatuslineTextAccent#"
  if branch == "" then
    return ""
  end
  return hl_accent .. " " .. hl_main .. branch .. _spacer(2)
end

local function get_recording()
  local hl_main = "%#StatuslineTextMain#"
  local hl_accent = "%#StatuslineTextAccent#"
  local noice = lazy_require "noice"
  local status = noice.api.status.mode.get()
  if status == nil then
    return ""
  end
  return hl_accent .. " " .. hl_main .. status .. _spacer(2)
end

local function get_percentage()
  if is_truncated(75) then
    return ""
  end
  local current_line = vim.fn.line "."
  local total_lines = vim.fn.line "$"
  local percent = vim.fn.floor(current_line / total_lines * 100)
  local content = ""
  local hl_bold = "%#StatuslineTextBold#"
  local hl_accent = "%#StatuslineTextAccent#"
  if current_line == 1 then
    content = "TOP"
  elseif current_line == total_lines then
    content = "END"
  elseif percent < 10 then
    content = hl_accent .. "·" .. hl_bold .. percent .. "%%"
  else
    content = percent .. "%%"
  end
  return hl_accent .. "≡ " .. hl_bold .. content .. _spacer(2)
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
    get_filetype(),
    get_path(),
    get_filename(),
    get_modification_status(),
    get_arrow_status(),
    get_lsp_status(),
    get_formatter_status(),
    get_copilot_status(),
    _align(),
    get_diagnostics(),
    get_recording(),
    get_dotnet_solution(),
    get_branch(),
    get_percentage(),
    _truncate(),
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
