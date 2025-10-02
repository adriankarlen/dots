return {
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {
      hints = {
        ["[dcyvV][ia][%(%)]"] = {
          message = function(keys)
            return "Use " .. keys:sub(1, 2) .. "b instead of " .. keys
          end,
          length = 3,
        },
      },
    },
    keys = {
      { "<leader>th", "<cmd>Hardtime toggle<cr>", desc = "hardtime" },
    },
  },
  {
    "mistweaverco/kulala.nvim",
    keys = {
      { "<leader>rs", desc = "send request" },
      { "<leader>ra", desc = "send all requests" },
      { "<leader>rb", desc = "open scratchpad" },
    },
    ft = { "http", "rest" },
    opts = {},
  },
  {
    "tris203/precognition.nvim",
    opts = {
      highlightColor = { link = "Comment" },
    },
    keys = {
      {
        "<leader>tp",
        function()
          require("precognition").toggle()
        end,
        desc = "precognition",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local config = require "nvim-treesitter.configs"
      config.setup {
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        ignore_install = {},
        ensure_installed = { "regex" },
        sync_install = false,
        modules = {},
      }
      vim.treesitter.language.register("markdown", "mdx")
    end,
  },
}
