return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = {},
      bufdelete = {},
      dashboard = {
        formats = {
          key = function(item)
            return { { "[", hl = "function" }, { item.key, hl = "key" }, { "]", hl = "function" } }
          end,
          header = { "%s", align = "center", hl = "MiniIconsBlue" },
          icon = function(item)
            if item.file and item.icon == "file" or item.icon == "directory" then
              return Snacks.dashboard.icon(item.file, item.icon)
            end
            return { item.icon, width = 2, hl = "MiniIconsPurple" }
          end,
        },
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "find file", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "w", desc = "find text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "e", desc = "explorer", action = ":lua require('mini.files').open()" },
            { icon = " ", key = "g", desc = "browse git", action = ":lua Snacks.lazygit()" },
            { icon = "󰒲 ", key = "l", desc = "lazy", action = ":Lazy" },
            { icon = "󱌣 ", key = "m", desc = "mason", action = ":Mason" },
            { icon = "󰭿 ", key = "q", desc = "quit", action = ":qa" },
          },
          header = require("utils.ascii").snufkin,
        },
        sections = {
          {
            section = "terminal",
            cmd = "chafa ~/.config/arctic-sunset.png --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1",
            height = 17,
            padding = 1,
          },
          {
            pane = 2,
            { title = "shortcuts", hl = "" },
            { section = "keys", padding = 1 },
            { title = "mru ", file = vim.fn.fnamemodify(".", ":~"), padding = 1 },
            { section = "recent_files", cwd = true, limit = 5, padding = 1 },
            { section = "startup" },
          },
        },
      },
      git = {},
      indent = {
        indent = {
          enabled = false,
        },
        animate = {
          enabled = false,
        },
        scope = {
          treesitter = {
            enabled = true,
          }
        },
      },
      lazygit = {
        theme = {
          activeBorderColor = { fg = "DiagnosticWarn", bold = true },
          searchingActiveBorderColor = { fg = "DiagnosticWarn", bold = true },
        },
      },
      notifier = {
        timeout = 3000,
      },
      statuscolumn = {},
      rename = {},
      terminal = {},
      styles = {
        notification = {
          border = "single",
          wo = { wrap = true, winblend = 0 }, -- Wrap notifications
        },
        ["notification.history"] = {
          border = "single",
        },
        lazygit = {
          border = "single",
        },
        blame_line = {
          border = "single",
          title = "git blame",
        },
      },
    },
    keys = {
    -- stylua: ignore start
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "delete buffer" },
    { "<leader>gb", function() Snacks.git.blame_line() end, desc = "blame line" },
    { "<leader>gl", function() Snacks.lazygit() end, desc = "lazygit" },
    { "<leader>cR", function() Snacks.rename() end, desc = "rename file" },
    { "<leader>fn", function() Snacks.notifier.show_history() end, desc = "notification history" },
    { "<leader><leader>", function() Snacks.terminal() end, desc = "terminal" },
      -- stylua: ignore end
    },
    init = function()
      -- Setup some globals for debugging (lazy-loaded)
      _G.dd = function(...)
        Snacks.debug.inspect(...)
      end
      _G.bt = function()
        Snacks.debug.backtrace()
      end
      vim.print = _G.dd -- Override print to use snacks for `:=` command
    end,
  },
}
