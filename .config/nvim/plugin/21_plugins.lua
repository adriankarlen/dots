---@diagnostic disable: param-type-mismatch, missing-fields
local add = vim.pack.add
local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- ─[ load at startup ]────────────────────────────────────────────────────
now(function()
  add { { src = "https://github.com/rose-pine/neovim", name = "rose-pine" } }
  require("rose-pine").setup {
    highlight_groups = {
      MatchParen = { fg = "love", bg = "love", blend = 25 },
    },
  }

  vim.cmd.colorscheme "rose-pine"
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
    gopls = {},
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
  require("mason-lspconfig").setup()

  for server_name, config in pairs(servers) do
    vim.lsp.config(server_name, config)
  end

  vim.lsp.inline_completion.enable()
end)

-- ─[ load if opened with file ]───────────────────────────────────────────
now_if_args(function()
  add { "https://github.com/rafamadriz/friendly-snippets" }
end)

now_if_args(function()
  add { "https://github.com/folke/lazydev.nvim" }
  require("lazydev").setup {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "mini" },
    },
  }
end)

now_if_args(function()
  add { "https://github.com/seblyng/roslyn.nvim" }
  require("roslyn").setup()
end)

-- ─[ lazy load ]────────────────────────────────────────────────────
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
      formatters = {
        biome = {
          require_cwd = true,
        },
      },
      formatters_by_ft = {
        sh = { "shfmt" },
        zsh = { "shfmt" },
        lua = { "stylua" },
        javascript = { "biome-check", "prettier", stop_after_first = true },
        javascriptreact = { "biome-check", "prettier", stop_after_first = true },
        typescript = { "biome-check", "prettier", stop_after_first = true },
        typescriptreact = { "biome-check", "prettier", stop_after_first = true },
        svelte = { "biome-check", "rustywind" },
        json = { "biome" },
        go = { "gofmt" },
        xml = { "xmlformatter" },
        svg = { "xmlformatter" },
      },
    },
  }
end)

later(function()
  add { "https://github.com/folke/sidekick.nvim" }
  require("sidekick").setup {
    nes = { enabled = false },
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

later(function()
  add { "https://github.com/windwp/nvim-ts-autotag" }
  require("nvim-ts-autotag").setup()
end)
