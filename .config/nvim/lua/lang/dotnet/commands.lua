local M = {}

local error = function(msg)
  vim.notify(msg, 4)
end

local get_all_csproj = function()
  local scandir = require "plenary.scandir"
  local result = {}
  local cwd = vim.fn.getcwd():gsub("\\", "/")
  local csproj_files = scandir.scan_dir(cwd, {
    hidden = false, -- Include hidden files (those starting with .)
    only_dirs = false, -- Include both files and directories
    depth = 5, -- Set the depth of search
    search_pattern = "%.csproj$", -- Lua pattern to match .csproj files
  })

  if csproj_files == nil then
    error "No csproj files found"
  end
  for _, value in ipairs(csproj_files) do
    local path = value:gsub("\\", "/")
    table.insert(result, path)
  end
  return result
end

local check_csproj = function(csproj)
  if csproj and csproj:match "%.csproj" then
    return true
  end
  return false
end

local execute = function(cmd)
  local all_csproj = get_all_csproj()
  local terminal_opts = {
    win = {
      position = "bottom",
    },
  }
  if vim.g.dotnet_utils.last_used_csproj == nil then
    vim.ui.select(all_csproj, {
      prompt = "select project",
      format_item = function(item)
        local csproj = vim.fs.basename(item)
        local icon, _, _ = require("mini.icons").get("file", csproj)
        local without_extenstion = vim.fn.fnamemodify(csproj, ":r2")
        return icon .. " " .. without_extenstion
      end,
    }, function(choice)
      if not check_csproj(choice) then
        error "invalid csproj path"
      end
      vim.g.dotnet_utils.last_used_csproj = choice

      Snacks.terminal.toggle(cmd .. choice, terminal_opts)
    end)
  else
    Snacks.terminal.toggle(cmd .. vim.g.dotnet_utils.last_used_csproj, terminal_opts)
  end
end

M.build = function()
  execute "dotnet build "
end

M.watch = function()
  execute "dotnet watch --project "
end

M.setup = function()
  vim.g.dotnet_utils = {
    last_used_csproj = nil,
  }
  -- stylua: ignore start 
  vim.keymap.set("n", "<leader>nw", function () M.watch() end, { desc = "watch project", noremap = true })
  vim.keymap.set("n", "<leader>nb", function () M.build() end, { desc = "build project", noremap = true })
  -- stylua: ignore end
end

return M
