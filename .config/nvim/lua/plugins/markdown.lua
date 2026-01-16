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
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = function()
      local presets = require "markview.presets"
      return {
        markdown = {
          heading = presets.headings.marker,
          horizonatal_rules = presets.horizontal_rules.dashed,
        },
        preview = {
          icon_provider = "mini",
        },
      }
    end,
    keys = {
      -- stylua: ignore start
      { "<leader>tm", "<cmd>Markview toggle<cr>", desc = "toggle markview" },
      -- stylua: ignore end
    },
  },
}
