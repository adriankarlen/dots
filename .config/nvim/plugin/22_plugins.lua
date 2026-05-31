local add = vim.pack.add
local gh, now, now_if_args, later = Config.gh, Config.now, Config.now_if_args, Config.later

-- ─[ load at startup ]────────────────────────────────────────────────────
now(function()
  local ts_update = function()
    vim.cmd "TSUpdate"
  end
  Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

  add {
    gh "nvim-treesitter/nvim-treesitter",
    gh "nvim-treesitter/nvim-treesitter-textobjects",
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

now_if_args(function()
  add { gh "neovim/nvim-lspconfig" }

  vim.lsp.enable {
    "bashls",
    "biome",
    "copilot",
    "cssls",
    "eslint",
    "emmylua_ls",
    "gopls",
    "html",
    "marksman",
    "roslyn_ls",
    "svelte",
    "tailwindcss",
    "taplo",
    "vtsls",
    "yamlls",
  }

  vim.lsp.inline_completion.enable()
end)

-- ─[ load if opened with file ]───────────────────────────────────────────
now_if_args(function()
  add { gh "rafamadriz/friendly-snippets" }
end)

now_if_args(function()
  add { gh "folke/lazydev.nvim" }
  ---@diagnostic disable-next-line: missing-fields, param-type-mismatch
  require("lazydev").setup {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "mini" },
    },
  }
end)

-- ─[ lazy load ]────────────────────────────────────────────────────
later(function()
  add { gh "stevearc/conform.nvim" }

  ---@diagnostic disable-next-line: param-type-mismatch
  require("conform").setup {
    default_format_opts = {
      lsp_format = "fallback",
    },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      if vim.bo[bufnr].buftype ~= "" then
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
  }
end)

later(function()
  add { gh "folke/sidekick.nvim" }
  ---@diagnostic disable-next-line: missing-fields, param-type-mismatch
  require("sidekick").setup {
    nes = { enabled = false },
    mux = { enabled = true },
  }
end)

later(function()
  add { gh "nvim-zh/colorful-winsep.nvim" }
  require("colorful-winsep").setup {
    animate = { enabled = false },
  }
end)

later(function()
  add { gh "dmmulroy/ts-error-translator.nvim" }
  require("ts-error-translator").setup()
end)

later(function()
  add { gh "christoomey/vim-tmux-navigator" }
end)

later(function()
  add { gh "windwp/nvim-ts-autotag" }
  require("nvim-ts-autotag").setup()
end)
