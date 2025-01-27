return {
  { "echasnovski/mini.ai", version = false, event = "BufReadPre", opts = { n_lines = 500 } },
  { "echasnovski/mini.align", version = false, event = "BufReadPre", opts = {} },
  { "echasnovski/mini.bracketed", version = false, event = "BufReadPre", opts = {} },
  { "echasnovski/mini-git", version = false, main = "mini.git", opts = {} },
  { "echasnovski/mini.operators", version = false, event = "BufReadPre", opts = { replace = { prefix = "gR" } } },
  {
    "echasnovski/mini.cursorword",
    version = false,
    event = "BufReadPre",
    config = function()
      require("mini.cursorword").setup()
      vim.api.nvim_create_autocmd({ "FileType" }, {
        desc = "Disable indentscope for certain filetypes",
        callback = function()
          local ignore_filetypes = {
            "dashboard",
            "help",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
          }
          if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
            vim.b.minicursorword_disable = true
          end
        end,
      })
    end,
  },
  {
    "echasnovski/mini.diff",
    version = false,
    
    opts = {
      view = {
        style = "sign",
        signs = { add = "┃", change = "┃", delete = "_" },
      },
    },
  },
  {
    "echasnovski/mini.files",
    version = false,
    
    config = function()
      require("mini.files").setup {
        windows = {
          width_preview = 60,
          width_focus = 40,
          preview = true,
        },
        mappings = {
          go_in_plus = "<tab>",
          go_out_plus = "<s-tab>",
        },
      }
      local ns_mini_files = vim.api.nvim_create_namespace "mini_files_git"
      local autocmd = vim.api.nvim_create_autocmd
      local _, MiniFiles = pcall(require, "mini.files")

      -- Cache for git status
      local git_status_cache = {}
      local cache_timeout = 2000 -- Cache timeout in milliseconds

      local function map_symbols(status)
        local status_map = {
          -- stylua: ignore start 
          [" M"] = { symbol = "•", hl_group  = "MiniDiffSignChange"}, -- Modified in the working directory
          ["M "] = { symbol = "✹", hl_group  = "MiniDiffSignChange"}, -- modified in index
          ["MM"] = { symbol = "≠", hl_group  = "MiniDiffSignChange"}, -- modified in both working tree and index
          ["A "] = { symbol = "+", hl_group  = "MiniDiffSignAdd"   }, -- Added to the staging area, new file
          ["AA"] = { symbol = "≈", hl_group  = "MiniDiffSignAdd"   }, -- file is added in both working tree and index
          ["D "] = { symbol = "-", hl_group  = "MiniDiffSignDelete"}, -- Deleted from the staging area
          ["AM"] = { symbol = "⊕", hl_group  = "MiniDiffSignChange"}, -- added in working tree, modified in index
          ["AD"] = { symbol = "-•", hl_group = "MiniDiffSignChange"}, -- Added in the index and deleted in the working directory
          ["R "] = { symbol = "→", hl_group  = "MiniDiffSignChange"}, -- Renamed in the index
          ["U "] = { symbol = "‖", hl_group  = "MiniDiffSignChange"}, -- Unmerged path
          ["UU"] = { symbol = "⇄", hl_group  = "MiniDiffSignAdd"   }, -- file is unmerged
          ["UA"] = { symbol = "⊕", hl_group  = "MiniDiffSignAdd"   }, -- file is unmerged and added in working tree
          ["??"] = { symbol = "?", hl_group  = "MiniDiffSignDelete"}, -- Untracked files
          ["!!"] = { symbol = "!", hl_group  = "MiniDiffSignChange"}, -- Ignored files
          -- stylua: ignore end
        }

        local result = status_map[status] or { symbol = "?", hl_group = "NonText" }
        return result.symbol, result.hl_group
      end

      local function fetch_git_status(cwd, callback)
        local stdout = (vim.uv or vim.loop).new_pipe(false)
        _, _ = (vim.uv or vim.loop).spawn(
          "git",
          {
            args = { "status", "--ignored", "--porcelain" },
            cwd = cwd,
            stdio = { nil, stdout, nil },
          },
          vim.schedule_wrap(function(code, _)
            if code == 0 then
              stdout:read_start(function(_, content)
                if content then
                  callback(content)
                  vim.g.content = content
                end
                stdout:close()
              end)
            else
              vim.notify("Git command failed with exit code: " .. code, vim.log.levels.ERROR)
              stdout:close()
            end
          end)
        )
      end

      local function escape_pattern(str)
        return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
      end

      local function update_mini_with_git(buf_id, git_status_map)
        vim.schedule(function()
          local nlines = vim.api.nvim_buf_line_count(buf_id)
          local cwd = vim.fn.getcwd() --  vim.fn.expand("%:p:h")
          local escaped_cwd = escape_pattern(cwd)
          if vim.fn.has "win32" == 1 then
            escaped_cwd = escaped_cwd:gsub("\\", "/")
          end

          for i = 1, nlines do
            local entry = MiniFiles.get_fs_entry(buf_id, i)
            if not entry then
              break
            end
            local relative_path = entry.path:gsub("^" .. escaped_cwd .. "/", "")
            local status = git_status_map[relative_path]

            if status then
              local symbol, hl_group = map_symbols(status)
              vim.api.nvim_buf_set_extmark(buf_id, ns_mini_files, i - 1, 0, {
                virt_text = { { symbol, hl_group } },
                virt_text_pos = "right_align",
                priority = 2,
              })
            else
            end
          end
        end)
      end

      local function is_valid_git_repo()
        if vim.fn.isdirectory ".git" == 0 then
          return false
        end
        return true
      end

      -- Thanks for the idea of gettings https://github.com/refractalize/oil-git-status.nvim signs for dirs
      local function parse_git_status(content)
        local git_status_map = {}
        -- lua match is faster than vim.split (in my experience )
        for line in content:gmatch "[^\r\n]+" do
          local status, filePath = string.match(line, "^(..)%s+(.*)")
          -- Split the file path into parts
          local parts = {}
          for part in filePath:gmatch "[^/]+" do
            table.insert(parts, part)
          end
          -- Start with the root directory
          local current_key = ""
          for i, part in ipairs(parts) do
            if i > 1 then
              -- Concatenate parts with a separator to create a unique key
              current_key = current_key .. "/" .. part
            else
              current_key = part
            end
            -- If it's the last part, it's a file, so add it with its status
            if i == #parts then
              git_status_map[current_key] = status
            else
              -- If it's not the last part, it's a directory. Check if it exists, if not, add it.
              if not git_status_map[current_key] then
                git_status_map[current_key] = status
              end
            end
          end
        end
        return git_status_map
      end

      local function update_git_status(buf_id)
        if not is_valid_git_repo() then
          return
        end
        local cwd = vim.fn.expand "%:p:h"
        local current_time = os.time()
        if git_status_cache[cwd] and current_time - git_status_cache[cwd].time < cache_timeout then
          update_mini_with_git(buf_id, git_status_cache[cwd].status_map)
        else
          fetch_git_status(cwd, function(content)
            local git_status_map = parse_git_status(content)
            git_status_cache[cwd] = {
              time = current_time,
              status_map = git_status_map,
            }
            update_mini_with_git(buf_id, git_status_map)
          end)
        end
      end

      local function clear_cache()
        git_status_cache = {}
      end

      local function augroup(name)
        return vim.api.nvim_create_augroup("MiniFiles_" .. name, { clear = true })
      end

      local show_git_dir = false
      local filter_show = function(_)
        return true
      end

      local filter_hide = function(fs_entry)
        return fs_entry.path:sub(-4) ~= ".git"
      end

      local apply_filter = function(filter)
        MiniFiles.refresh { content = { filter = filter } }
      end

      local toggle_git_dir_hide = function()
        show_git_dir = not show_git_dir
        local filter = show_git_dir and filter_show or filter_hide
        apply_filter(filter)
      end

      autocmd("User", {
        group = augroup "start",
        pattern = "MiniFilesExplorerOpen",
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          update_git_status(bufnr)
          local filter = show_git_dir and filter_show or filter_hide
          apply_filter(filter)
        end,
      })

      autocmd("User", {
        group = augroup "close",
        pattern = "MiniFilesExplorerClose",
        callback = function()
          clear_cache()
        end,
      })

      autocmd("User", {
        group = augroup "update",
        pattern = "MiniFilesBufferUpdate",
        callback = function(sii)
          local bufnr = sii.data.buf_id
          local cwd = vim.fn.expand "%:p:h"
          if git_status_cache[cwd] then
            update_mini_with_git(bufnr, git_status_cache[cwd].status_map)
          end
        end,
      })

      autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          -- Tweak left-hand side of mapping to your liking
          vim.keymap.set("n", "g.", toggle_git_dir_hide, { buffer = buf_id })
        end,
      })

      autocmd("User", {
        pattern = "MiniFilesWindowUpdate",
        callback = function(args)
          local config = vim.api.nvim_win_get_config(args.data.win_id)
          config.height = 15
          vim.api.nvim_win_set_config(args.data.win_id, config)
        end,
      })

      autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event)
          Snacks.rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
    end,
    keys = {
      {
        "<leader>e",
        function()
          local current_file = vim.fn.expand "%"
          local _ = require("mini.files").close() or require("mini.files").open(current_file, false)
          vim.schedule(function()
            vim.defer_fn(function()
              vim.cmd "normal @"
            end, 10)
          end)
        end,
        desc = "explorer",
      },
    },
  },
  {
    "echasnovski/mini.icons",
    opts = {
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["init.lua"] = { glyph = "󰢱", hl = "MiniIconsAzure" },
      },
      lsp = {
        copilot = { glyph = "", hl = "MiniIconsOrange" },
        snippet = { glyph = "" },
      },
    },
    
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  {
    "echasnovski/mini.move",
    version = false,
    event = "BufReadPre",
    opts = {
      mappings = {
        left = "<",
        down = "-",
        up = "_",
        right = ">",
        line_left = "<",
        line_down = "-",
        line_up = "_",
        line_right = ">",
      },
    },
  },
  { "echasnovski/mini.pairs", version = false, event = "InsertEnter", opts = {} },
  {
    "echasnovski/mini.splitjoin",
    version = false,
    event = "BufReadPre",
    opts = { mappings = { toggle = "<leader>cm" } },
  },
  { "echasnovski/mini.surround", event = "BufReadPre", version = false, opts = {} },
  { "echasnovski/mini.doc", version = false, opts = {}, ft = "lua" },
}
