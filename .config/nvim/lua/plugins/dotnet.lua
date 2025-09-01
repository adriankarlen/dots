return {
  {
    enabled = vim.fn.executable "dotnet" == 1,
    "seblj/roslyn.nvim",
    ft = "cs",
    event = "BufReadPre",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {},
    keys = {
      { "<leader>nl", "<cmd>Roslyn restart<cr>", desc = "restart roslyn lsp" },
    },
  },
  {
    "GustavEikaas/easy-dotnet.nvim",
    enabled = vim.fn.executable "dotnet" == 1,
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "cs", "vb", "csproj", "sln", "slnx", "props", "csx", "targets" },
    cmd = "Dotnet",
    opts = {
      terminal = function(path, action)
        local commands = {
          run = function()
            return "dotnet run --project " .. path
          end,
          test = function()
            return "dotnet test " .. path
          end,
          restore = function()
            return "dotnet restore " .. path
          end,
          build = function()
            return "dotnet build " .. path
          end,
        }
        local cmd = commands[action]() .. "\r"
        Snacks.terminal.open(cmd)
      end,
      test_runner = {
        viewmode = "float",
        icons = {
          project = "󰗀",
        },
      },
    },
    keys = {
      -- stylua: ignore start 
      { "<leader>nB", function() require("easy-dotnet").build_quickfix() end, desc = "build solution" },
      { "<leader>nr", function() require("easy-dotnet").run_default() end, desc = "run" },
      { "<leader>nR", function() require("easy-dotnet").run_solution() end, desc = "run solution" },
      { "<leader>nx", function() require("easy-dotnet").clean() end, desc = "clean solution" },
      { "<leader>na", "<cmd>Dotnet new<cr>", desc = "new item" },
      { "<leader>nt", "<cmd>Dotnet testrunner<cr>", desc = "open test runner" },
      -- stylua: ignore end
    },
  },
}
