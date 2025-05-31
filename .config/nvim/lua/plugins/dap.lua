return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap, dapui = require "dap", require "dapui"
      dap.set_log_level "TRACE"

      dap.listeners.after.event_initialized.dapui_config = function()
        dapui.open()
        vim.cmd("colorscheme " .. vim.g.colors_name)
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      vim.fn.sign_define(
        "DapBreakpoint",
        { text = "", texthl = "DiagnosticError", linehl = "DapBreakpoint", numhl = "" }
      )
      vim.fn.sign_define("DapStopped", { text = "󰳟", texthl = "", linehl = "DapStopped", numhl = "" })

      require("dap-config.netcore").register_net_dap()
    end,
    keys = {
      -- stylua: ignore start
      {"<leader>dc", function() require("dap").continue() end, noremap = true, silent = true, desc = "continue",},
      {"<leader>do", function() require("dap").step_over() end, noremap = true, silent = true, desc = "step over",},
      {"<leader>di", function() require("dap").step_into() end, noremap = true, silent = true, desc = "step into",},
      {"<leader>du", function() require("dap").step_out() end, noremap = true, silent = true, desc = "step out",},
      {"<leader>dr", function() require("dap").restart() end, noremap = true, silent = true, desc = "restart",},
      {"<leader>dt", function() require("dap").terminate() end, noremap = true, silent = true, desc = "terminate",},
      {"<leader>db", function() require("dap").toggle_breakpoint() end, noremap = true, silent = true, desc = "toggle breakpoint",},
      -- stylua: ignore end
    },
    dependencies = {
      {
        "igorlfs/nvim-dap-view",
        opts = {},
      },
    },
  },
}
