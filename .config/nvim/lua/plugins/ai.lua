return {
  {
    "folke/sidekick.nvim",
    lazy = false,
    opts = {
      cli = {
        mux = {
          backend = "tmux",
          enabled = true,
        },
      },
    },
    keys = {
      {
        "<tab>",
        function()
          if require("sidekick").nes_jump_or_apply() then
            return
          end
          if vim.lsp.inline_completion.get() then
            return
          end
          return "<tab>"
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle { focus = true }
        end,
        desc = "Sidekick Toggle CLI",
        mode = { "n", "v" },
      },
      {
        "<leader>ao",
        function()
          require("sidekick.cli").toggle { name = "opencode", focus = true }
        end,
        desc = "toggle opencode",
        mode = { "n", "v" },
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        desc = "ask prompt",
        mode = { "n", "v" },
      },
    },
  },
}
