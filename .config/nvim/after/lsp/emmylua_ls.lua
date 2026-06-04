-- Adjust semantic token highlighting:
-- - Don't extra highlight keywords, tree-sitter seems to do a better job
vim.api.nvim_set_hl(0, "@lsp.type.keyword.lua", { fg = "NONE" })
-- - Don't extra highlight strings, tree-sitter injections do much better job
vim.api.nvim_set_hl(0, "@lsp.type.string.lua", { fg = "NONE" })
-- - But still highlight special words in documentation (like ---@param).
vim.api.nvim_set_hl(0, "@lsp.mod.documentation.lua", { link = "Statement" })

return {
  settings = {
    emmylua = {
      diagnostics = {
        disable = { "undefined-global" },
      },
      runtime = { version = "LuaJIT" },
      workspace = {
        library = vim.list_extend({ vim.env.VIMRUNTIME }, vim.api.nvim_get_runtime_file("lua", true)),
        ignoreDir = { "dual", "deps" },
      },
    },
  },
}
