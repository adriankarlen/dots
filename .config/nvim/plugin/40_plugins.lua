---@diagnostic disable: param-type-mismatch, missing-fields
local add = vim.pack.add
local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- ─[ load at startup ]────────────────────────────────────────────────────
now(function()
  add { { src = "https://github.com/rose-pine/neovim", name = "rose-pine" } }
  require("rose-pine").setup {
    highlight_groups = {
      MatchParen = { fg = "love", bg = "love", blend = 25 },
      SnacksDashboardFile = { fg = "text" },
      SnacksDashboardDesc = { link = "NonText" },
      SnacksDashboardTitle = { fg = "iris", bold = true },
    },
  }

  vim.cmd.colorscheme "rose-pine"
end)

now(function()
  add { "https://github.com/folke/snacks.nvim" }
  require("snacks").setup {
    bigfile = { enabled = true },
    rename = { enabled = true },
    terminal = {
      win = {
        size = { width = 0.8, height = 0.8 },
        border = "solid",
      },
    },
    picker = {
      layout = {
        preset = "minimal",
      },
      layouts = {
        minimal = {
          preview = false,
          layout = {
            backdrop = false,
            height = 0.35,
            width = 0.5,
            box = "horizontal",
            {
              border = "solid",
              box = "vertical",
              title = "{title}",
              title_pos = "left",
              { win = "input", height = 1,     border = "bottom" },
              { win = "list",  border = "none" },
            },
            { win = "preview", title = "{preview}", title_pos = "left", border = "solid" },
          },
        },
      },
      previewers = {
        diff = {
          builtin = false,
          cmd = { "delta" },
        },
      },
      sources = {
        grep = {
          layout = {
            preview = true,
          },
        },
        icons = {
          layout = {
            preset = "minimal",
          },
        },
        select = {
          layout = {
            preset = "minimal",
          },
        },
      },
    },
    input = {
      enabled = true,
      backdrop = true,
    },
  }
end)

now(function()
  local ts_update = function()
    vim.cmd "TSUpdate"
  end
  Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

  add {
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  }

  local languages = {
    "bash",
    "c_sharp",
    "comment",
    "css",
    "dockerfile",
    "editorconfig",
    "git_config",
    "gitattributes",
    "gitignore",
    "html",
    "go",
    "javascript",
    "jsdoc",
    "json",
    "jsx",
    "lua",
    "luadoc",
    "markdown",
    "markdown_inline",
    "nginx",
    "nix",
    "query",
    "regex",
    "powershell",
    "svelte",
    "tmux",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
    "zsh",
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then
    require("nvim-treesitter").install(to_install)
  end

  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev)
    vim.treesitter.start(ev.buf)
  end
  Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
end)

now(function()
  add {
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim",
  }

  local servers = {
    bashls = {},
    cssls = {
      settings = {
        css = {
          validate = true,
          lint = {
            unknownAtRules = "ignore",
          },
        },
        scss = {
          validate = true,
          lint = {
            unknownAtRules = "ignore",
          },
        },
        less = {
          validate = true,
          lint = {
            unknownAtRules = "ignore",
          },
        },
      },
    },
    eslint = {},
    biome = {},
    html = {},
    emmylua_ls = {},
    marksman = {},
    roslyn = {
      settings = {
        ["csharp|inlay_hints"] = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
        },
        ["csharp|code_lens"] = {
          dotnet_enable_references_code_lens = true,
        },
      },
    },
    svelte = {},
    tailwindcss = {},
    taplo = {},
    vtsls = {},
    yamlls = {},
    copilot = {},
  }

  require("mason").setup {
    registries = {
      "github:mason-org/mason-registry",
      "github:Crashdummyy/mason-registry",
    },
  }
  require("mason-lspconfig").setup {}

  for server_name, config in pairs(servers) do
    vim.lsp.config(server_name, config)
  end

  vim.lsp.inline_completion.enable()
end)

-- ─[ load if opened with file ]───────────────────────────────────────────

-- ─[ load lazily ]────────────────────────────────────────────────────────
later(function()
  add { "https://github.com/stevearc/conform.nvim" }

  require("conform").setup {
    default_format_opts = {
      lsp_format = "fallback",
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return {
          timeout_ms = 500,
        }
      end,
      formatters_by_ft = {
        sh = { "shfmt" },
        zsh = { "shfmt" },
        lua = { "stylua" },
        javascript = { "biome-check" },
        javascriptreact = { "biome-check" },
        typescript = { "biome-check" },
        typescriptreact = { "biome-check" },
        svelte = { "biome-check", "rustywind" },
        json = { "biome" },
        go = { "gofmt" },
        xml = { "xmlformatter" },
        svg = { "xmlformatter" },
      },
    },
  }
end)

now_if_args(function()
  add { "https://github.com/rafamadriz/friendly-snippets" }
end)

now_if_args(function()
  add { "https://github.com/folke/lazydev.nvim" }
  require("lazydev").setup {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "snacks.nvim",        words = { "Snacks" } },
      { path = "mini" },
    },
  }
end)

now_if_args(function()
  add { "https://github.com/catgoose/nvim-colorizer.lua" }
  require("colorizer").setup {
    user_default_options = {
      names = false,
      mode = "virtualtext",
      virtualtext = " ",
      virtualtext_inline = "before",
    },
  }
end)

now_if_args(function()
  add { { src = "https://github.com/saghen/blink.cmp", version = vim.version.range "*" } }
  require("blink.cmp").setup {
    completion = {
      menu = {
        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                return kind_icon
              end,
              highlight = function(ctx)
                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
            kind = {
              highlight = function(ctx)
                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
          },
        },
      },
    },
    cmdline = {
      completion = {
        menu = {
          auto_show = true,
        },
      },
    },
    keymap = {
      ["<Tab>"] = {
        "snippet_forward",
        function()
          return require("sidekick").nes_jump_or_apply()
        end,
        function()
          return vim.lsp.inline_completion.get()
        end,
        "fallback",
      },
    },
    sources = {
      default = { "lazydev", "lsp", "path", "snippets", "buffer" },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
      },
    },
  }
end)

-- ─[ lazy load ]────────────────────────────────────────────────────
later(function()
  add { "https://github.com/folke/sidekick.nvim" }
  require("sidekick").setup()
end)

later(function()
  add { "https://github.com/stevearc/oil.nvim" }

  -- helper function to parse output
  local function parse_output(proc)
    local result = proc:wait()
    local ret = {}
    if result.code == 0 then
      for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
        -- Remove trailing slash
        local lineWithoutSlash = line:gsub("/$", "")
        ret[lineWithoutSlash] = true
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

  require("oil").setup {
    float = {
      max_height = 0.35,
      max_width = 0.5,
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
      border = "solid",
    },
    keymaps_help = {
      border = "solid",
    },
  }
end)

later(function()
  add { "https://github.com/folke/which-key.nvim" }
  require("which-key").setup {
    preset = "helix",
    win = { border = "solid" },
    spec = {
      -- groups
      { "<leader>a", mode = { "n", "x" }, group = "ai", icon = { icon = "󱙺" } },
      { "<leader>b", group = "buffer", icon = "" },
      { "<leader>e", group = "explore", icon = "󰙅" },
      { "<leader>f", mode = { "n", "x" }, group = "find", icon = "󰍉" },
      { "<leader>g", mode = { "n", "x" }, group = "git", icon = { icon = "", color = "green" } },
      { "<leader>l", mode = { "n", "x" }, group = "language", icon = "" },
      { "<leader>m", group = "map", icon = "" },
      { "<leader>o", group = "other", icon = "" },
      { "<leader>s", group = "session" },
      -- commands
      { "<leader>ap", icon = "󰻞" },
      { "<leader>bd", icon = "󰯈" },
      { "<leader>bD", icon = "󰯈" },
      { "<leader>bw", icon = "󰯈" },
      { "<leader>bW", icon = "󰯈" },
      { "<leader>ef", icon = "󰈤" },
      { "<leader>la", icon = "󱐌" },
      { "<leader>lf", icon = "" },
    },
  }
end)

later(function()
  add { "https://github.com/nvim-zh/colorful-winsep.nvim" }
  require("colorful-winsep").setup {
    animate = { enabled = false },
  }
end)

later(function()
  add { "https://github.com/dmmulroy/ts-error-translator.nvim" }
  require("ts-error-translator").setup()
end)

later(function()
  add { "https://github.com/dmmulroy/tsc.nvim" }
  require("tsc").setup()
end)

later(function()
  add { "https://github.com/christoomey/vim-tmux-navigator" }
end)
