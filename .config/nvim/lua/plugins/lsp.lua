return {
  "neovim/nvim-lspconfig",
  cond = not vim.g.vscode,
  lazy = false,
  dependencies = {
    { "williamboman/mason.nvim", config = true },
    { "williamboman/mason-lspconfig.nvim" },
    { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  },
  config = function()
    local servers = {
      bashls = {},
      cssls = {
        settings = {
          css = { validate = true, lint = {
            unknownAtRules = "ignore",
          } },
          scss = { validate = true, lint = {
            unknownAtRules = "ignore",
          } },
          less = { validate = true, lint = {
            unknownAtRules = "ignore",
          } },
        },
      },
      eslint = {},
      gopls = {},
      html = {},
      jsonls = {},
      emmylua_ls = {},
      marksman = {},
      roslyn = {
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
          },
        },
      },
      svelte = {},
      tailwindcss = {},
      taplo = {},
      vtsls = {},
      yamlls = {},
      copilot = {},
    }

    require("mason").setup {
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
        "github:Crashdummyy/mason-registry",
      },
    }
    require("mason-lspconfig").setup {
      automatic_enable = true,
      automatic_installation = true,
    }

    local ensure_installed = vim.tbl_keys(servers)
    vim.list_extend(ensure_installed, {
      "prettier", -- prettier formatter
      "stylua", -- lua formatter
      "rustywind", -- tailwindcss formatter
      "xmlformatter", -- xml formatter
      "shfmt", -- shell script formatter
    })

    require("mason-tool-installer").setup { ensure_installed = ensure_installed }

    for server_name, config in pairs(servers) do
      vim.lsp.config(server_name, config)
    end

    vim.lsp.inline_completion.enable()
  end,
  keys = {
    -- stylua: ignore start
    { "gD", "<cmd>Trouble lsp_declarations<cr>", desc = "lsp declaration" },
    { "gd", "<cmd>Trouble lsp_definitions<cr>", desc = "lsp definition" },
    { "gi", "<cmd>Trouble lsp_implementations<cr>", desc = "lsp implementation" },
    { "gr", "<cmd>Trouble lsp_references<cr>", desc = "lsp references" },
    { "gy", "<cmd>Trouble lsp_type_definitions<cr>", desc = "lsp type definition" },
    -- stylua: ignore start
  },
}
