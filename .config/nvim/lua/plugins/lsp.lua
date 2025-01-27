return {
  "neovim/nvim-lspconfig",
  cond = not vim.g.vscode,
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  dependencies = {
    { "williamboman/mason.nvim", config = true },
    { "williamboman/mason-lspconfig.nvim" },
    { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  },
  config = function()
    local mason = require "mason"
    local mason_tool_installer = require "mason-tool-installer"
    local mason_lspconfig = require "mason-lspconfig"

    local servers = {
      cssls = {},
      eslint = {},
      gopls = {},
      html = {},
      jsonls = {},
      -- lemminx = {},
      lua_ls = {},
      marksman = {},
      -- powershell_es = {
      --   bundle_path = vim.fn.stdpath "data" .. "/mason/packages/powershell-editor-services",
      --   init_options = {
      --     enableProfileLoading = false,
      --   },
      -- },
      svelte = {},
      tailwindcss = {},
      taplo = {},
      vtsls = {},
      yamlls = {},
    }

    local ensure_installed = vim.tbl_keys(servers)
    vim.list_extend(ensure_installed, {
      -- "csharpier", -- c# formatter
      -- "netcoredbg", -- c# debugger
      "prettier", -- prettier formatter
      "stylua", -- lua formatter
      -- "xmlformatter", -- xml formatter
    })

    mason.setup {
      max_concurrent_installers = 10,
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "",
        },
        border = "single",
      },
      registries = {
        "github:mason-org/mason-registry",
        "github:syndim/mason-registry",
      },
    }
    mason_tool_installer.setup { ensure_installed = ensure_installed }
    mason_lspconfig.setup {
      ensure_installed = {},
      automatic_installation = true,
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = require("blink.cmp").get_lsp_capabilities(server.capabilities or {})
          require("lspconfig")[server_name].setup(server)
        end,
      },
    }
  end,
  keys = {
    -- stylua: ignore start
    { "[d", function() vim.lsp.diagnostic.goto_prev()end, desc = "lsp goto prev diagnostic" },
    { "]d", function() vim.lsp.diagnostic.goto_next()end, desc = "lsp goto next diagnostic" },
    { "gD", "<cmd>Trouble lsp_declarations<cr>", desc = "lsp declaration" },
    { "gd", "<cmd>Trouble lsp_definitions<cr>", desc = "lsp definition" },
    { "gi", "<cmd>Trouble lsp_implementations<cr>", desc = "lsp implementation" },
    { "gk", function() vim.lsp.buf.hover()end, desc = "lsp hover" },
    { "gr", "<cmd>Trouble lsp_references<cr>", desc = "lsp references" },
    { "gy", "<cmd>Trouble lsp_type_definitions<cr>", desc = "lsp type definition" },
    -- stylua: ignore start
  },
}
