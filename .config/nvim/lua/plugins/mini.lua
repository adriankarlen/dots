return {
  { "nvim-mini/mini.ai", version = false, event = "VeryLazy", opts = { n_lines = 500 } },
  { "nvim-mini/mini.jump", version = false, event = "BufReadPre", opts = {} },
  { "nvim-mini/mini.bracketed", version = false, event = "VeryLazy", opts = {} },
  { "nvim-mini/mini-git", version = false, main = "mini.git", event = "VeryLazy", opts = {} },
  { "nvim-mini/mini.operators", version = false, event = "BufReadPre", opts = {} },
  { "nvim-mini/mini.comment", version = false, opts = {} },
  { "nvim-mini/mini.surround", event = "BufReadPre", version = false, opts = {} },
  { "nvim-mini/mini.doc", version = false, opts = {}, ft = "lua" },
  {
    "nvim-mini/mini.trailspace",
    version = false,
    event = "BufReadPre",
    opts = {},
    keys = {
      --stylua: ignore start
      { "<leader>ct", function() require("mini.trailspace").trim() end, desc = "trim trailing whitespace" },
      --stylua: ignore end
    },
  },
  {
    "nvim-mini/mini.notify",
    version = false,
    event = "VeryLazy",
    opts = {
      content = {
        format = function(notif)
          local time = vim.fn.strftime("%H:%M:%S", math.floor(notif.ts_update))
          return string.format("%s   %s", time, notif.msg)
        end,
      },
      window = { config = { title = "" }, winblend = 0 },
    },
    init = function()
      vim.notify = require("mini.notify").make_notify()
    end,
  },
  {
    "nvim-mini/mini.cursorword",
    version = false,
    event = "BufReadPre",
    config = function()
      require("mini.cursorword").setup()
      vim.api.nvim_create_autocmd({ "FileType" }, {
        desc = "Disable indentscope for certain filetypes",
        callback = function()
          local ignore_filetypes = {
            "dashboard",
            "help",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
          }
          if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
            vim.b.minicursorword_disable = true
          end
        end,
      })
    end,
  },
  {
    "nvim-mini/mini.diff",
    version = false,
    event = "VeryLazy",
    opts = {
      view = {
        style = "sign",
        signs = { add = "┃", change = "┃", delete = "_" },
      },
    },
    keys = {
      {
        "<leader>gd",
        function()
          MiniDiff.toggle_overlay(0)
        end,
        desc = "toggle diff overlay",
      },
    },
  },
  {
    "nvim-mini/mini.icons",
    opts = {
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["init.lua"] = { glyph = "󰢱", hl = "MiniIconsAzure" },
      },
      lsp = {
        copilot = { glyph = "", hl = "MiniIconsOrange" },
        snippet = { glyph = "" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  {
    "nvim-mini/mini.move",
    version = false,
    event = "BufReadPre",
    opts = {
      mappings = {
        left = "<",
        down = "-",
        up = "_",
        right = ">",
        line_left = "<",
        line_down = "-",
        line_up = "_",
        line_right = ">",
      },
    },
  },
  {
    "nvim-mini/mini.pairs",
    version = false,
    event = "InsertEnter",
    opts = {
      mappings = {
        ["["] = { action = "open", pair = "[]", neigh_pattern = ".[%s%z%)}%]]", register = { cr = false } },
        ["{"] = { action = "open", pair = "{}", neigh_pattern = ".[%s%z%)}%]]", register = { cr = false } },
        ["("] = { action = "open", pair = "()", neigh_pattern = ".[%s%z%)]", register = { cr = false } },
        ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^%w\\][^%w]", register = { cr = false } },
        ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%w\\][^%w]", register = { cr = false } },
        ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^%w\\][^%w]", register = { cr = false } },
      },
    },
  },
  {
    "nvim-mini/mini.splitjoin",
    version = false,
    event = "BufReadPre",
    opts = { mappings = { toggle = "<leader>cm" } },
  },
}
