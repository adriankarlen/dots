return {
  "stevearc/conform.nvim",
  cond = not vim.g.vscode,
  
  event = { "BufWritePre" },
  config = function()
    require("conform").setup {
      quiet = true,
      lsp_fallback = true,
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier", "eslint", stop_after_first = true },
        typescript = { "prettier", "eslint", stop_after_first = true },
        javascriptreact = { "prettier", "rustywind" },
        typescriptreact = { "prettier", "rustywind" },
        svelte = { "prettier", "rustywind" },
        html = { "prettier", "rustywind" },
        css = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        mdx = { "prettier" },
        graphql = { "prettier" },
        go = { "gofmt"},
        cs = { "csharpier" },
        xml = { "xmlformat" },
        svg = { "xmlformat" },
        rust = { "rustfmt" },
      },
      formatters = {
        xmlformat = {
          cmd = { "xmlformat" },
          args = { "--selfclose", "-" },
        },
        injected = { options = { ignore_errors = false } },
      },
    }
  end,
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format()
      end,
      desc = "format",
      silent = true,
    },
  },
}
