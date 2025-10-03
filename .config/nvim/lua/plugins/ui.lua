return {
  {
    "Chaitanyabsprip/fastaction.nvim",
    event = "VeryLazy",
    enabled = false,
    opts = {
      register_ui_select = true,
      popup = {
        x_offset = vim.api.nvim_get_option_value("columns", {}),
        border = "single",
        title = "select:",
      },
    },
    keys = {
      -- stylua: ignore start
      { "<leader>ca", function() require("fastaction").code_action() end, desc = "code action", buffer = true },
      -- stylua: ignore end
    },
  },
  {
    "stevearc/oil.nvim",
    opts = function()
      -- helper function to parse output
      local function parse_output(proc)
        local result = proc:wait()
        local ret = {}
        if result.code == 0 then
          for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
            -- Remove trailing slash
            line = line:gsub("/$", "")
            ret[line] = true
          end
        end
        return ret
      end
      -- build git status cache
      local function new_git_status()
        return setmetatable({}, {
          __index = function(self, key)
            local ignore_proc = vim.system(
              { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
              {
                cwd = key,
                text = true,
              }
            )
            local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
              cwd = key,
              text = true,
            })
            local ret = {
              ignored = parse_output(ignore_proc),
              tracked = parse_output(tracked_proc),
            }
            rawset(self, key, ret)
            return ret
          end,
        })
      end
      local git_status = new_git_status()

      -- Clear git status cache on refresh
      local refresh = require("oil.actions").refresh
      local orig_refresh = refresh.callback
      refresh.callback = function(...)
        git_status = new_git_status()
        orig_refresh(...)
      end
      return {
        float = {
          max_width = 0.4,
          max_height = 0.25,
        },
        view_options = {
          is_hidden_file = function(name, bufnr)
            local dir = require("oil").get_current_dir(bufnr)
            local is_dotfile = vim.startswith(name, ".") and name ~= ".."
            -- if no local directory (e.g. for ssh connections), just hide dotfiles
            if not dir then
              return is_dotfile
            end
            -- dotfiles are considered hidden unless tracked
            if is_dotfile then
              return not git_status[dir].tracked[name]
            else
              -- Check if file is gitignored
              return git_status[dir].ignored[name]
            end
          end,
        },
        keymaps = {
          ["<tab>"] = "actions.select",
          ["<s-tab>"] = "actions.parent",
          ["q"] = { "actions.close", mode = "n" },
          ["§"] = { "actions.cd", mode = "n" },
          ["°"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
          ["g'"] = { "actions.toggle_trash", mode = "n" },
        },
        ssh = {
          border = "single",
        },

        keymaps_help = {
          border = "single",
        },
      }
    end,
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    lazy = false,
    keys = {
      -- stylua: ignore start
      { "<leader>e", function() require("oil").toggle_float() end, desc = "toggle oil" },
      -- stylua: ignore end
    },
  },
  {
    "folke/edgy.nvim",
    event = { "BufReadPre" },
    opts = function(_, opts)
      opts = {
        animate = {
          enabled = false,
        },
        bottom = {
          { ft = "qf", title = "quickfix" },
          {
            ft = "help",
            size = { height = 20 },
            -- only show help buffers
            filter = function(buf)
              return vim.bo[buf].buftype == "help"
            end,
          },
        },
        right = {
          { title = "grug far", ft = "grug-far", size = { width = 0.4 } },
          { title = "copilot chat", ft = "copilot-chat", size = { width = 50 } },
          { title = "code companion", ft = "codecompanion", size = { width = 50 } },
        },
      }

      --snacks terminal
      for _, pos in ipairs { "top", "bottom", "left", "right" } do
        opts[pos] = opts[pos] or {}
        table.insert(opts[pos], {
          ft = "snacks_terminal",
          size = { height = 0.4 },
          title = "%{b:snacks_terminal.id}",
          filter = function(_, win)
            return vim.w[win].snacks_win
              and vim.w[win].snacks_win.position == pos
              and vim.w[win].snacks_win.relative == "editor"
              and not vim.w[win].trouble_preview
          end,
        })
      end

      -- trouble
      for _, pos in ipairs { "top", "bottom", "left", "right" } do
        opts[pos] = opts[pos] or {}
        table.insert(opts[pos], {
          ft = "trouble",
          filter = function(_, win)
            return vim.w[win].trouble
              and vim.w[win].trouble.position == pos
              and vim.w[win].trouble.type == "split"
              and vim.w[win].trouble.relative == "editor"
              and not vim.w[win].trouble_preview
          end,
        })
      end
      return opts
    end,
  },
  {
    "nvim-zh/colorful-winsep.nvim",
    event = { "BufReadPre" },
    opts = function(_, opts)
      local palette = require "rose-pine.palette"
      opts = {
        hi = {
          fg = palette.gold,
        },
        smooth = false,
      }
      return opts
    end,
  },
  {
    "iofq/dart.nvim",
    event = "BufReadPre",
    opts = {
      buflist = {},
      tabline = {
        always_show = false,
        label_fg = "",
      },
      picker = {
        border = "single",
      },
    },
  },
  {
    "rachartier/tiny-code-action.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "LspAttach",
    opts = {
      backend = "delta",
      picker = {
        "buffer",
        opts = {
          hotkeys = true,
          hotkeys_mode = "text_diff_based",
          auto_accept = true,
          position = "cursor",
        },
      },
    },
    keys = {
      {
        "<leader>ca",
        function()
          ---@diagnostic disable-next-line: missing-parameter
          require("tiny-code-action").code_action()
        end,
        desc = "code action",
        mode = { "n", "x" },
        buffer = true,
      },
    },
  },
}
