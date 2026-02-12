return {
  "rose-pine/neovim",
  lazy = false,
  name = "rose-pine",
  config = function()
    require("rose-pine").setup {
      highlight_groups = {
        MatchParen = { fg = "love", bg = "love", blend = 25 },
        EasyDotnetTestRunnerSolution = { fg = "pine" },
        EasyDotnetTestRunnerProject = { fg = "rose" },
        EasyDotnetTestRunnerTest = { fg = "iris" },
        SnacksIndentScope = { fg = "muted" },
        SnacksDashboardSpecial = { fg = "muted", italic = true },
        SnacksDashboardTitle = { fg = "text" },
        SnacksDashboardDesc = { fg = "muted" },
        SnacksDashboardDir = { fg = "muted", italic = true },
        SnacksDashboardFile = { fg = "text" },
        SnacksDashboardFooter = { fg = "text" },
        OilGitAdded = { fg = "foam" },
        OilGitModified = { fg = "rose" },
        OilGitRenamed = { fg = "pine" },
        OilGitUntracked = { fg = "subtle" },
        OilGitIgnored = { fg = "muted" },
      },
    }
    vim.cmd "colorscheme rose-pine"
  end,
}
