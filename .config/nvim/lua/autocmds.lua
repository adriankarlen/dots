local autocmd = vim.api.nvim_create_autocmd

-- dont list quickfix buffers
autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.opt_local.buflisted = false
  end,
})

autocmd("VimResized", {
  pattern = "*",
  command = "tabdo wincmd =",
})

autocmd("User", {
  pattern = "OilActionsPost",
  callback = function(event)
      if event.data.actions.type == "move" then
          Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
      end
  end,
})
autocmd("User", {
  pattern = { "SnacksDashboardOpened", "SnacksDashboardUpdatePost" },
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local conf = vim.api.nvim_win_get_config(win)
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].ft
      if ft == "snacks_dashboard" and conf.relative ~= "" then
        vim.api.nvim_win_set_config(win, { border = "none" })
      end
    end
  end,
})
