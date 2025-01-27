local M = {}

--- Rebuilds the project before starting the debug session
---@param co thread
local function rebuild_project(co, path)
  vim.notify "Building project"
  vim.fn.jobstart(string.format("dotnet build %s", path), {
    on_exit = function(_, return_code)
      if return_code == 0 then
        vim.notify "Built successfully"
      else
        vim.notify("Build failed with exit code " .. return_code)
      end
      coroutine.resume(co)
    end,
  })
  coroutine.yield()
end

M.register_net_dap = function()
  local dap = require "dap"
  local dotnet = require "easy-dotnet"

  local debug_dll = nil
  local function ensure_dll()
    if debug_dll ~= nil then
      return debug_dll
    end
    local dll = dotnet.get_debug_dll()
    debug_dll = dll
    return dll
  end

  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "launch - netcoredbg",
      request = "launch",
      env = function()
        local dll = ensure_dll()
        -- Reads the launchsettingsjson file looking for a profile with the name of your project
        local vars = dotnet.get_environment_variables(dll.project_name, dll.relative_project_path)
        return vars or nil
      end,
      program = function()
        local dll = ensure_dll()
        local co = coroutine.running()
        rebuild_project(co, dll.project_path)
        return dll.relative_dll_path
      end,
      cwd = function()
        local dll = ensure_dll()
        return dll.relative_project_path
      end,
    },
  }

  dap.listeners.before["event_terminated"]["easy-dotnet"] = function()
    debug_dll = nil
  end

  dap.adapters.coreclr = {
    type = "executable",
    command = "netcoredbg",
    args = { "--interpreter=vscode" },
  }
end

return M
