-- Formatting without plugins ==================================================
-- Uses buffer-local 'formatprg' set per filetype (see after/ftplugin/).
-- Runs program over stdin, applies output only on exit 0, falls back to LSP.

local H = {}

-- Helpers =====================================================================

H.buf_dir = function()
  return vim.fn.expand "%:p:h"
end

-- Check if package.json has a field, e.g. "prettier".
H.pkg_has = function(field)
  ---@diagnostic disable-next-line: param-type-mismatch
  local pkg = vim.fs.find("package.json", { path = H.buf_dir(), upward = true, type = "file" })[1]
  if not pkg then
    return false
  end
  for line in io.lines(pkg) do
    if line:find(field, 1, true) then
      return true
    end
  end
  return false
end

-- Prepare cmd for formatters that need filename for EditorConfig resolution
H.fixup_cmd = function(cmd, bufname)
  if bufname == "" then
    return cmd
  end

  -- shfmt ignores EditorConfig on stdin unless --filename is provided
  if cmd[1]:match "shfmt$" then
    if cmd[#cmd] == "-" then
      table.remove(cmd)
    end
    table.insert(cmd, "--filename")
    table.insert(cmd, bufname)
  end

  return cmd
end

-- Check if any LSP client supports formatting
H.has_lsp_formatter = function(bufnr)
  bufnr = bufnr or 0
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  for _, client in ipairs(clients) do
    if client:supports_method "textDocument/formatting" then
      return true
    end
  end
  return false
end

-- Public API ==================================================================

-- Detect and set buffer-local 'formatprg' for prettier projects.
Config.set_formatprg = function()
  if H.pkg_has '"prettier"' then
    vim.bo.formatprg = "prettierd --stdin-filepath " .. vim.fn.expand "%:p"
  end
end

-- Format current buffer via 'formatprg', or fall back to LSP.
Config.format = function()
  local prg = vim.bo.formatprg
  if prg == "" then
    if not H.has_lsp_formatter() then
      return
    end
    return vim.lsp.buf.format()
  end

  local bufname = vim.api.nvim_buf_get_name(0)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local cmd = vim.split(vim.fn.expandcmd(prg), " ", { trimempty = true })
  cmd = H.fixup_cmd(cmd, bufname)

  local out = vim.system(cmd, { stdin = lines, text = true, cwd = vim.fs.dirname(bufname) }):wait()

  if out.code ~= 0 then
    return vim.notify(string.format("[%s] %s", cmd[1], out.stderr or "format failed"), vim.log.levels.ERROR)
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(out.stdout or "", "\n", { trimempty = true }))
end

-- Format on save ==============================================================

vim.g.format_on_save = true

Config.new_autocmd("BufWritePre", "*", function()
  if vim.bo.buftype ~= "" then
    return
  end
  local enabled = vim.b.format_on_save
  if enabled == nil then
    enabled = vim.g.format_on_save
  end
  if enabled then
    Config.format()
  end
end, "Format on save")
