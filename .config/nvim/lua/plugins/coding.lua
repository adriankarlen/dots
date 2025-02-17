return {
  {
    "windwp/nvim-ts-autotag",
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
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {},
    keys = {
      {
        "<leader>cr",
        function()
          return ":IncRename " .. vim.fn.expand "<cword>"
        end,
        expr = true,
        desc = "rename",
      },
    },
  },
  { "folke/ts-comments.nvim", event = "BufReadPre", opts = {} },
  {
    "antonk52/npm_scripts.nvim",
    opts = {
      select_script_prompt = "select script",
      run_script = function(opts)
        local cmd = opts.package_manager .. " run " .. opts.name
        require("snacks").terminal.toggle(cmd, { win = { position = "bottom", interactive = true } })
      end,
    },
    keys = {
      -- stylua: ignore start
      { "<leader>jr", function() require("npm_scripts").run_script() end, desc = "run npm script" },
      -- stylua: ignore end
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
    opts = {
      document_color = {
        -- enabled = false,
        inline_symbol = " ",
      },
      conceal = {
        enabled = true,
      },
    },
    keys = {
      { "<leader>co", "<cmd>TailwindSort(Sync)<cr>", desc = "tailwind sort" },
      { "<leader>co", mode = "x", "<cmd>TailwindSortSelection(Sync)<cr>", desc = "tailwind sort" },
      { "<leader>tt", "<cmd>TailwindConcealToggle<cr>", desc = "tailwind conceal"}
    },
  },
}
