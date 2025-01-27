local autocmd = vim.api.nvim_create_autocmd

-- dont list quickfix buffers
autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.opt_local.buflisted = false
  end,
})

autocmd("VimResized", {
  pattern = "*",
  command = "tabdo wincmd =",
})

local meter = {
  "▰ ▱ ▱ ▱ ▱ ▱ ▱ ",
  "▰ ▰ ▱ ▱ ▱ ▱ ▱ ",
  "▰ ▰ ▰ ▱ ▱ ▱ ▱ ",
  "▰ ▰ ▰ ▰ ▱ ▱ ▱ ",
  "▰ ▰ ▰ ▰ ▰ ▱ ▱ ",
  "▰ ▰ ▰ ▰ ▰ ▰ ▱ ",
  "▰ ▰ ▰ ▰ ▰ ▰ ▰ ",
}

local generate_meter = function(status)
  -- Ensure status is between 0 and 100
  if status < 0 then
    status = 0
  end
  if status >= 100 then
    return ""
  end

  -- Calculate the index (1-8)
  local index = math.ceil(status / 100 * #meter)
  if index == 0 then
    index = 1
  end

  -- Return the corresponding string from meter
  return ("[%s]"):format(meter[index])
end

---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
local progress = vim.defaulttable()

autocmd("LspProgress", {
  ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
    if not client or type(value) ~= "table" then
      return
    end
    local p = progress[client.id]

    for i = 1, #p + 1 do
      if i == #p + 1 or p[i].token == ev.data.params.token then
        p[i] = {
          token = ev.data.params.token,
          msg = ("%s %s%s"):format(
            generate_meter(value.kind == "end" and 100 or value.percentage or 100),
            value.title or "",
            value.message and (" **%s**"):format(value.message) or ""
          ),
          done = value.kind == "end",
        }
        break
      end
    end

    local msg = {} ---@type string[]
    progress[client.id] = vim.tbl_filter(function(v)
      return table.insert(msg, v.msg) or not v.done
    end, p)
    vim.notify(table.concat(msg, "\n"), "warn", {
      id = "lsp_progress",
      title = client.name,
      opts = function(notif)
        notif.icon = #progress[client.id] == 0 and " "
          or ""
      end,
    })
  end,
})
