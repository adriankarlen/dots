return {
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    ft = {
      "html",
      "svelte",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "markdown",
      "xml",
    },
  },
  {
    "dmmulroy/tsc.nvim",
    event = "LspAttach",
    opts = {},
    keys = {
      { "<leader>jt", "<cmd>TSC<cr>", desc = "typecheck project" },
    },
  },
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {
      input_buffer_type = "snacks",
    },
    keys = {
      {
        "<leader>cr",
        function()
          return ":IncRename "
        end,
        expr = true,
        desc = "rename",
      },
    },
  },
  {
    "luckasRanarison/tailwind-tools.nvim",
    name = "tailwind-tools",
    ft = { "html", "typescriptreact", "javascriptreact", "svelte" },
    build = ":UpdateRemotePlugins",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "neovim/nvim-lspconfig",
    },
    keys = {
      { "<leader>co", "<cmd>TailwindSort(Sync)<cr>", desc = "tailwind sort" },
      { "<leader>co", mode = "x", "<cmd>TailwindSortSelection(Sync)<cr>", desc = "tailwind sort" },
      { "<leader>tt", "<cmd>TailwindConcealToggle<cr>", desc = "tailwind conceal" },
    },
  },
}
