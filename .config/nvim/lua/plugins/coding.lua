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
        Snacks.terminal.toggle(cmd, { win = { position = "bottom", interactive = true } })
      end,
    },
    keys = {
      -- stylua: ignore start
      { "<leader>jr", function() require("npm_scripts").run_script() end, desc = "run npm script" },
      -- stylua: ignore end
    },
  },
}
