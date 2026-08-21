local H = {}

-- Returns the major version of a `typescript` package.json's version string,
-- or nil if it can't be determined.
H.ts_major_from_pkg = function(pkg_path)
  if vim.fn.filereadable(pkg_path) == 0 then
    return nil
  end
  local ok, content = pcall(vim.fn.readfile, pkg_path)
  if not ok then
    return nil
  end
  local ok2, decoded = pcall(vim.json.decode, table.concat(content, "\n"))
  if not ok2 or not decoded or type(decoded.version) ~= "string" then
    return nil
  end
  local major = decoded.version:match "^(%d+)"
  return major and tonumber(major) or nil
end

-- Walks up from bufnr looking for the nearest `node_modules/typescript`,
-- skipping any node_modules dirs that don't have typescript installed
-- (e.g. a parent monorepo root when the leaf package has its own install).
-- Returns root, major or nil, nil.
H.find_ts_root = function(bufnr)
  local start = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  for _, node_modules in ipairs(vim.fs.find("node_modules", { upward = true, path = start, limit = math.huge })) do
    local root = vim.fs.dirname(node_modules)
    local major = H.ts_major_from_pkg(node_modules .. "/typescript/package.json")
    if major then
      return root, major
    end
  end
  return nil, nil
end

---@type vim.lsp.Config
return {
  on_attach = function(client)
    -- Biome handles formatting; prevent tsc from competing.
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
  root_dir = function(bufnr, on_dir)
    -- This lsp speaks the TS7+ protocol and crashes on init against older
    -- typescript, so the nearest installed `typescript` package doubles as
    -- both the root marker and the version gate.
    local root, ts_major = H.find_ts_root(bufnr)
    if not root or ts_major < 7 then
      return
    end

    -- Bail out if a deno project root is at or below this root (deno takes
    -- over even if npm-compat node_modules/typescript is present).
    local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" })
    if deno_root and #deno_root >= #root then
      return
    end

    on_dir(root)
  end,
}
