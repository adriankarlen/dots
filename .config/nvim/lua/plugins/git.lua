-- autocmd that only loads git plugins if within a git repo
vim.api.nvim_create_autocmd({ "BufRead" }, {
  group = vim.api.nvim_create_augroup("LazyLoadGitPlugins", { clear = true }),
  callback = function()
    vim.fn.jobstart({ "git", "-C", vim.loop.cwd(), "rev-parse" }, {
      on_exit = function(_, return_code)
        if return_code == 0 then
          vim.api.nvim_del_augroup_by_name "LazyLoadGitPlugins"
          vim.schedule(function()
            require("lazy").load { plugins = { "mini.diff", "mini-git", "git-conflict.nvim" } }
          end)
        end
      end,
    })
  end,
})

-- Use only HEAD name as summary string
local format_summary = function(data)
  -- Utilize buffer-local table summary
  local summary = vim.b[data.buf].minigit_summary
  vim.b[data.buf].minigit_summary_string = summary.head_name or ""
end

local au_opts = { pattern = "MiniGitUpdated", callback = format_summary }
vim.api.nvim_create_autocmd("User", au_opts)

return {
  {
    "akinsho/git-conflict.nvim",
    
    version = "*",
    opts = {},
  },
}
