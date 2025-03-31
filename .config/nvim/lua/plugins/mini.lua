return {
  { "echasnovski/mini.ai", version = false, event = "BufReadPre", opts = { n_lines = 500 } },
  { "echasnovski/mini.align", version = false, event = "BufReadPre", opts = {} },
  { "echasnovski/mini.bracketed", version = false, event = "BufReadPre", opts = {} },
  { "echasnovski/mini-git", version = false, main = "mini.git", opts = {} },
  { "echasnovski/mini.operators", version = false, event = "BufReadPre", opts = { replace = { prefix = "gR" } } },
  {
    "echasnovski/mini.cursorword",
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
    "echasnovski/mini.diff",
    version = false,
    opts = {
      view = {
        style = "sign",
        signs = { add = "┃", change = "┃", delete = "_" },
      },
    },
  },
  {
    "echasnovski/mini.icons",
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
    "echasnovski/mini.move",
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
  { "echasnovski/mini.pairs", version = false, event = "InsertEnter", opts = {} },
  {
    "echasnovski/mini.splitjoin",
    version = false,
    event = "BufReadPre",
    opts = { mappings = { toggle = "<leader>cm" } },
  },
  { "echasnovski/mini.surround", event = "BufReadPre", version = false, opts = {} },
  { "echasnovski/mini.doc", version = false, opts = {}, ft = "lua" },
}
