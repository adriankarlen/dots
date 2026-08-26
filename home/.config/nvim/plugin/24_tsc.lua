-- Utility commands =============================================================

local H = {}

-- Helpers =====================================================================

H.parse_tsc_line = function(line)
  local file, lnum, col, msg = line:match "^(.-)%((%d+),(%d+)%):%s+(.+)$"
  if not file then
    return nil
  end
  return { filename = file, lnum = tonumber(lnum), col = tonumber(col), text = msg, type = "E" }
end

-- Public API ==================================================================

-- Run project-local tsc and populate quickfix with errors
Config.tsc = function()
  local bin = vim.fs.find("node_modules/.bin/tsc", { upward = true, type = "file" })[1]
  if not bin then
    return vim.notify("tsc: not found in node_modules", vim.log.levels.ERROR)
  end

  vim.notify("tsc: running...", vim.log.levels.INFO)

  vim.system(
    { bin, "--noEmit", "--pretty", "false" },
    { text = true },
    vim.schedule_wrap(function(result)
      local items = {}
      for _, line in ipairs(vim.split(result.stdout or "", "\n", { trimempty = true })) do
        local item = H.parse_tsc_line(line)
        if item then
          table.insert(items, item)
        end
      end

      vim.fn.setqflist({}, " ", { title = "tsc", items = items })

      if #items > 0 then
        vim.cmd "botright copen"
        vim.notify(string.format("tsc: %d error(s)", #items), vim.log.levels.ERROR)
      else
        vim.cmd "cclose"
        vim.notify("tsc: no errors", vim.log.levels.INFO)
      end
    end)
  )
end
