return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    enabled = vim.fn.executable "dotnet" == 1,
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {
      lsp = {
        enabled = false,
        roslynator_enabled = false,
      },
      terminal = function(path, action, args)
        args = args or ""
        local cmds = {
          run = function()
            return string.format("dotnet run --project %s %s", path, args)
          end,
          test = function()
            return string.format("dotnet test %s %s", path, args)
          end,
          restore = function()
            return string.format("dotnet restore %s %s", path, args)
          end,
          build = function()
            return string.format("dotnet build %s %s", path, args)
          end,
          watch = function()
            return string.format("dotnet watch --project %s %s", path, args)
          end,
        }
        local command = cmds[action]()
        Snacks.terminal.toggle(command)
      end,
      debugger = {
        --name if netcoredbg is in PATH or full path like 'C:\Users\gusta\AppData\Local\nvim-data\mason\bin\netcoredbg.cmd'
        bin_path = "netcoredbg",
      },
    },
    keys = {
      -- stylua: ignore start
      { "<leader>nb", function() require("easy-dotnet").build() end, desc = "build" },
      { "<leader>nB", function() require("easy-dotnet").build_quickfix() end, desc = "build solution" },
      { "<leader>nr", function() require("easy-dotnet").run_default() end, desc = "run" },
      { "<leader>nR", function() require("easy-dotnet").run_solution() end, desc = "run solution" },
      { "<leader>nw", function() require("easy-dotnet").watch() end, desc = "run watch" },
      { "<leader>nu", function() require("easy-dotnet").restore() end, desc = "restore" },
      { "<leader>nx", function() require("easy-dotnet").clean() end, desc = "clean solution" },
      { "<leader>na", function() require("easy-dotnet").new() end, desc = "new item" },
      { "<leader>nt", function() require("easy-dotnet").testrunner() end, desc = "open test runner" },
      -- stylua: ignore end
    },
  },
  {
    "seblyng/roslyn.nvim",
    enabled = vim.fn.executable "dotnet" == 1,
    lazy = false,
    opts = {},
  },
}
