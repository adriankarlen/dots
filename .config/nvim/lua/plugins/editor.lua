return {
  {
    "otavioschwanck/arrow.nvim",
    opts = {
      show_icons = true,
      leader_key = ",", -- Recommended to be a single key
      buffer_leader_key = "m", -- Per Buffer Mappings
    },
  },
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require "grug-far"
          local ext = vim.bo.buftype == "" and vim.fn.expand "%:e"
          grug.open {
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          }
        end,
        mode = { "n", "v" },
        desc = "search and replace",
      },
    },
  },
  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      user_default_options = {
        names = false,
        mode = "virtualtext",
        virtualtext = "",
        virtualtext_inline = "before",
      },
    },
  },
  {
    "mvllow/modes.nvim",
    event = "BufReadPre",
    opts = function()
      local palette = require "rose-pine.palette"
      return {
        colors = {
          bg = palette.base,
        },
      }
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    event = "BufRead",
    keys = {
      { "<leader>fc", "<cmd>Trouble todo<cr>", desc = "todo comments" },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
      modes = {
        preview_float = {
          mode = "diagnostics",
          preview = {
            type = "float",
            relative = "editor",
            border = "single",
            title = "Preview",
            title_pos = "center",
            position = { 0, -2 },
            size = { width = 0.3, height = 0.3 },
            zindex = 200,
          },
        },
      },
    },
    -- stylua: ignore start
    keys = {
      {"<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", desc = "workspace diagnostics" },
      {"<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "buffer diagnostics" },
      {"<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "symbols" },
      {"<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "lsp definitions / references / ..." },
      {"<leader>l", "<cmd>Trouble loclist toggle<cr>", desc = "location list" },
      {"<leader>q", "<cmd>Trouble qflist toggle<cr>", desc = "quickfix list" },
    },
    -- stylua: ignore end
  },
  {
    "folke/which-key.nvim",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    event = "VeryLazy",
    opts = {
      preset = "helix",
      win = { border = "single" },
      spec = {
        -- groups
        { "<leader>a", group = "ai", icon = { icon = "", color = "orange" } },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "hurl", icon = "" },
        { "<leader>j", group = "js", icon = "" },
        { "<leader>l", group = "lsp" },
        { "<leader>n", group = ".net", icon = "󰌛" },
        { "<leader>p", group = "packages", icon = "" },
        { "<leader>pn", group = "dotnet", icon = "󰌛" },
        { "<leader>s", group = "search/replace" },
        { "<leader>t", group = "toggle" },
        { "<leader>x", group = "diagnostics" },
        -- commands
        { "<leader>bd", icon = "󰭿" },
        { "<leader>bD", icon = "󰭿" },
        { "<leader>ca", icon = "󱐋" },
        { "<leader>cf", icon = "" },
        { "<leader>cm", icon = "󱓡", desc = "join/split block" },
        { "<leader>cr", icon = "󰏪" },
        { "<leader>db", icon = "󰃤" },
        { "<leader>e", icon = "󰙅" },
      },
      disable = {
        ft = {
          "lazygit",
          "snacks_terminal",
        },
      },
    },
  },
  {
    "yorickpeterse/nvim-pqf",
    ft = "qf",
    opts = {
      signs = {
        error = { text = "", hl = "DiagnosticSignError" },
        warning = { text = "", hl = "DiagnosticSignWarn" },
        info = { text = "", hl = "DiagnosticSignInfo" },
        hint = { text = "", hl = "DiagnosticSignHint" },
      },
    },
  },
}
