return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      require("lazy").load { plugins = { "markdown-preview.nvim" } }
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      { "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown Preview" },
    },
    config = function()
      vim.cmd [[do FileType]]
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    opts = {
      file_types = { "markdown", "copilot-chat", "codecompanion" },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = { " " }, -- stylua: ignore
        position = "inline",
      },
      pipe_table = { alignment_indicator = "┅" },
    },
    ft = { "markdown", "copilot-chat", "codecompanion" },
    keys = {
      -- stylua: ignore start
      { "<leader>tm", function() require('render-markdown').toggle() end, ft = { "markdown", "copilot-chat" }, desc = "toggle markdown rendering" },
      -- stylua: ignore end
    },
  },
}
