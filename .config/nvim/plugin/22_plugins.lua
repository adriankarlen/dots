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

-- ─[ load if opened with file ]───────────────────────────────────────────
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

now_if_args(function()
  add { gh "rafamadriz/friendly-snippets" }
end)

-- ─[ lazy load ]────────────────────────────────────────────────────
later(function()
  add { gh "stevearc/conform.nvim" }

  ---@diagnostic disable-next-line: param-type-mismatch
  require("conform").setup {
    default_format_opts = {
      lsp_format = "fallback",
      async = true,
    },
    format_on_save = function(bufnr)
      if vim.bo[bufnr].buftype ~= "" then
        return
      end
      return {
        timeout_ms = 1000,
      }
    end,
    formatters = {
      biome = {
        require_cwd = true,
      },
      ["biome-check"] = {
        require_cwd = true,
      },
      prettierd = {
        require_cwd = true,
      },
    },
    formatters_by_ft = {
      go = { "gofmt" },
      javascript = { "biome-check", "prettierd" },
      javascriptreact = { "biome-check", "prettierd" },
      json = { "biome", "prettierd" },
      lua = { "stylua" },
      sh = { "shfmt" },
      svelte = { "prettierd", "rustywind" },
      typescript = { "biome-check", "prettierd" },
      typescriptreact = { "biome-check", "prettierd" },
      zsh = { "shfmt" },
    },
  }
end)

later(function()
  add { gh "dmmulroy/ts-error-translator.nvim" }
  require("ts-error-translator").setup()
end)

later(function()
  add { gh "mrjones2014/smart-splits.nvim" }
end)

later(function()
  add { gh "windwp/nvim-ts-autotag" }
  require("nvim-ts-autotag").setup()
end)
