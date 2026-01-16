return {
  "stevearc/conform.nvim",
  cond = not vim.g.vscode,

  event = { "BufWritePre" },
  opts = {
    quiet = true,
    lsp_format = "fallback",
    formatters_by_ft = {
      sh = { "shfmt" },
      zsh = { "shfmt" },
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
      go = { "gofmt" },
      cs = { "roslyn" },
      xml = { "xmlformatter" },
      svg = { "xmlformatter" },
    },
    formatters = {
      xmlformatter = {
        cmd = { "xmlformatter" },
        args = { "--selfclose", "-" },
      },
      shfmt = {
        -- prepend_args = { "-i", "2", "-ci", "-bn" },
      },
      injected = { options = { ignore_errors = false } },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format {}
      end,
      desc = "format",
      silent = true,
    },
  },
}
