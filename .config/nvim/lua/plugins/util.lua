return {
  {
    "chrishrb/gx.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "Browse" },
    init = function()
      vim.g.netrw_nogx = 1
    end,
    submodules = false,
    opts = {
      handlers = {
        jira = {
          name = "jira",
          handle = function(mode, line, _)
            local ticket = require("gx.helper").find(line, mode, "(%u+-%d+)")
            if ticket and #ticket < 20 then
              return "http://jira.storebrand.no/browse/" .. ticket
            end
          end,
        },
      },
      handler_options = {
        search_engine = "https://search.brave.com/search?q=",
        select_for_search = false,
        git_remotes = { "upstream", "origin" },
        git_remote_push = true,
      },
    },
    keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
  },
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
    "jellydn/hurl.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = "hurl",
    opts = {
      show_notification = true,
      mode = "popup",
      env_file = {
        "vars.env",
        "env/at.env",
      },
    },
    keys = {
      -- Run API request
      { "<leader>hr", "<cmd>HurlRunnerAt<CR>", desc = "run api request", ft = "hurl" },
      { "<leader>ha", "<cmd>HurlRunner<CR>", desc = "run all requests", ft = "hurl" },
      { "<leader>hA", "<cmd>HurlVerbose<CR>", desc = "run api in verbose mode", ft = "hurl" },
      { "<leader>he", "<cmd>HurlRunnerToEntry<CR>", desc = "run api request to entry", ft = "hurl" },
      { "<leader>ht", "<cmd>HurlToggleMode<CR>", desc = "toggle popup/split result", ft = "hurl" },
      {
        "<leader>hv",
        function()
          local var_name = vim.fn.input "Enter env variable name: "
          local var_value = vim.fn.input "Enter env variable value: "
          if var_name ~= "" and var_value ~= "" then
            vim.cmd("HurlSetVariable " .. var_name .. " " .. var_value)
          end
        end,
        desc = "add env variable",
        ft = "hurl",
      },
      { "<leader>hm", "<cmd>HurlManageVariable<cr>", desc = "manage variable", ft = "hurl" },
      -- Run Hurl request in visual mode
      { "<leader>h", ":HurlRunner<CR>", desc = "Hurl Runner", mode = "v", ft = "hurl" },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
      },
    },
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
        ensure_installed = {},
        sync_install = false,
        modules = {},
      }
      vim.treesitter.language.register("markdown", "mdx")
    end,
  },
}
