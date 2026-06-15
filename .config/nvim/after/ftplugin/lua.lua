vim.bo.formatprg = "stylua --search-parent-directories --stdin-filepath " .. vim.fn.expand "%:p" .. " -"
