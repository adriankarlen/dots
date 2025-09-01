-- Add plugins
vim.pack.add({
  "https://github.com/Chaitanyabsprip/fastaction.nvim",
  "https://github.com/folke/noice.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/echasnovski/mini.icons",
  "https://github.com/folke/edgy.nvim",
  "https://github.com/nvim-zh/colorful-winsep.nvim",
  "https://github.com/iofq/dart.nvim"
})

-- FastAction setup
require("fastaction").setup({
  register_ui_select = true,
  popup = {
    x_offset = vim.api.nvim_get_option_value("columns", {}),
    border = "single",
    title = "select:",
  },
})
vim.keymap.set("n", "<leader>ca", function() require("fastaction").code_action() end, { desc = "code action", buffer = true })

-- Noice setup
require("noice").setup({
  lsp = {
    progress = { enabled = false },
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
  },
  notify = { enabled = false },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = true,
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        kind = "",
        find = "written",
      },
      opts = { skip = true },
    },
  },
  views = {
    mini = {
      position = {
        col = -2,
        row = -2,
      },
      win_options = {
        winblend = 0,
      },
      border = {
        style = "single",
      },
    },
    cmdline_input = {
      border = {
        style = "single",
      },
    },
    cmdline_popup = {
      border = {
        style = "single",
      },
    },
  },
})

-- Oil setup (keeping the existing function for git status)
local oil_opts = require("oil").setup_function() -- Your existing setup function
require("oil").setup(oil_opts)
vim.keymap.set("n", "<leader>e", function() require("oil").toggle_float() end, { desc = "toggle oil" })

-- Edgy setup
require("edgy").setup({
  animate = {
    enabled = false,
  },
  bottom = {
    { ft = "qf", title = "quickfix" },
    {
      ft = "help",
      size = { height = 20 },
      filter = function(buf)
        return vim.bo[buf].buftype == "help"
      end,
    },
  },
  right = {
    { title = "grug far", ft = "grug-far", size = { width = 0.4 } },
    { title = "copilot chat", ft = "copilot-chat", size = { width = 50 } },
    { title = "code companion", ft = "codecompanion", size = { width = 50 } },
  },
  -- Keeping your existing snacks and trouble configuration
})

-- Colorful-winsep setup
require("colorful-winsep").setup({
  hi = {
    fg = require("rose-pine.palette").gold,
  },
  smooth = false,
})

-- Dart setup
require("dart").setup({
  buflist = {},
  tabline = {
    always_show = false,
  },
  picker = {
    border = "single",
  },
})
