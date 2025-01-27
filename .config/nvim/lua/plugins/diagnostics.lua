return {
  {
    "OlegGulevskyy/better-ts-errors.nvim",
    ft = { "typescript", "typescriptreact" },
    event = "LspAttach",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      keymaps = {
        toggle = "<leader>xb",
        go_to_definition = "<leader>xB",
      },
    },
  },
  {
    "RaafatTurki/corn.nvim",
    event = "LspAttach",
    opts = {
      icons = {
        error = "",
        warn = "",
        info = "",
        hint = "",
      },
      blacklisted_modes = { "i" },
      -- toggle virtual_text diags when corn is toggled
      on_toggle = function(is_hidden)
        if is_hidden then
          vim.diagnostic.config { virtual_text = false }
          return
        end
        vim.diagnostic.config { virtual_text = { prefix = ">" } }
      end,
      item_preprocess_func = function(item)
        local max_width = vim.api.nvim_win_get_width(0) / 4
        local message = item.message
        local lines = {}

        while #message > max_width do
          table.insert(lines, string.sub(message, 1, max_width))
          message = string.sub(message, max_width + 1)
        end
        table.insert(lines, message)

        item.message = table.concat(lines, "\n")
        return item
      end,
    },
    keys = {
      {
        "<leader>tc",
        function()
          require("corn").toggle()
        end,
        desc = "corn",
      },
    },
  },
}
