local tsc = function()
  local bin = vim.fs.find("node_modules/.bin/tsc", { upward = true, type = "file" })[1]
  if not bin then
    vim.notify("tsc: not found in node_modules", vim.log.levels.ERROR)
    return
  end

  vim.notify("tsc: running...", vim.log.levels.INFO)

  vim.system(
    { bin, "--noEmit", "--pretty", "false" },
    { text = true },
    vim.schedule_wrap(function(result)
      local lines = vim.split(result.stdout or "", "\n", { trimempty = true })
      local items = {}

      for _, line in ipairs(lines) do
        local file, lnum, col, msg = line:match "^(.-)%((%d+),(%d+)%):%s+(.+)$"
        if file then
          table.insert(items, {
            filename = file,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = msg,
            type = "E",
          })
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

vim.api.nvim_create_user_command("TSC", tsc, { desc = "Run tsc type-check" })
