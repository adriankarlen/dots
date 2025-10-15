--lazy.nvim
--nvim-dap config
return {
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    config = function()
      local dap = require "dap"

      -- Keymaps for controlling the debugger
      vim.keymap.set("n", "q", function()
        dap.terminate()
        dap.clear_breakpoints()
      end, { desc = "Terminate and clear breakpoints" })

      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Start/continue debugging" })
      vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step over" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
      vim.keymap.set("n", "<leader>du", dap.step_out, { desc = "Step out" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<leader>dO", dap.step_over, { desc = "Step over (alt)" })
      vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "Run to cursor" })
      vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle DAP REPL" })
      vim.keymap.set("n", "<leader>dj", dap.down, { desc = "Go down stack frame" })
      vim.keymap.set("n", "<leader>dk", dap.up, { desc = "Go up stack frame" })

      -- .NET specific setup using `easy-dotnet`
      require("easy-dotnet.netcoredbg").register_dap_variables_viewer() -- special variables viewer specific for .NET
    end,
  },
  {
    "igorlfs/nvim-dap-view",
    event = "VeryLazy",
    opts = {},
  },
}
