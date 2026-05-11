local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

now(function()
  require("mini.basics").setup {
    options = { basic = false },
    mappings = {
      windows = true,
      move_with_alt = true,
    },
  }
end)

now(function()
  -- Set up to not prefer extension-based icon for some extensions
  local ext3_blocklist = { scm = true, txt = true, yml = true }
  local ext4_blocklist = { json = true, yaml = true }
  require("mini.icons").setup {
    use_file_extension = function(ext, _)
      return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
    end,

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
  }

  later(MiniIcons.mock_nvim_web_devicons)

  later(MiniIcons.tweak_lsp_kind)
end)

now(function()
  require("mini.notify").setup()
end)

now(function()
  require("mini.sessions").setup()
end)

now(function()
  local starter = require "mini.starter"
  local fortune = function()
    local ok, quote = pcall(function()
      local f = io.popen("fortune -s", "r")
      local s = assert(f:read "*a")
      f:close()
      return s
    end)
    return ok and quote or nil
  end
  starter.setup {
    evaluate_single = true,
    items = {
      starter.sections.recent_files(10, true),
      starter.sections.sessions(5, true),
      {
        { name = "Explore", action = "lua MiniFiles.open()", section = "Actions" },
        { name = "Find",    action = "Pick git_files",       section = "Actions" },
        { name = "Grep",    action = "Pick grep_live",       section = "Actions" },
        {
          name = "OpenCode",
          action = "lua require('sidekick.cli').toggle { name = 'opencode', focus = true }",
          section = "Actions",
        },
        { name = "Quit", action = "qall", section = "Actions" },
      },
    },
    footer = fortune(),
  }
end)

now(function()
  require("mini.tabline").setup()
end)

now(function()
  local function get_macro_status()
    local recording_register = vim.fn.reg_recording()
    if recording_register == "" then
      return ""
    end
    return "󰑊 Recording @" .. recording_register
  end
  require("mini.statusline").setup {
    content = {
      active = function()
        local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
        local diff = MiniStatusline.section_diff { trunc_width = 75 }
        local diagnostics = MiniStatusline.section_diagnostics { trunc_width = 75 }
        local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
        local filename = MiniStatusline.section_filename { trunc_width = 140 }
        local fileinfo = MiniStatusline.section_fileinfo { trunc_width = 120 }
        local location = MiniStatusline.section_location { trunc_width = 75 }
        local search = MiniStatusline.section_searchcount { trunc_width = 75 }
        local macro = get_macro_status()

        return MiniStatusline.combine_groups {
          { hl = mode_hl,                     strings = { mode } },
          { hl = "MiniStatuslineDevinfo",     strings = { git, diff, diagnostics, lsp } },
          { hl = "MiniStatuslineModeCommand", strings = { macro } },
          "%<", -- Mark general truncate point
          { hl = "MiniStatuslineFilename", strings = { filename } },
          "%=", -- End left alignment
          { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
          { hl = mode_hl,                  strings = { search, location } },
        }
      end,
    },
  }
end)

now_if_args(function()
  local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
  local process_items = function(items, base)
    return MiniCompletion.default_process_items(items, base, process_items_opts)
  end
  require("mini.completion").setup {
    lsp_completion = {
      source_func = "omnifunc",
      auto_setup = false,
      process_items = process_items,
    },
  }

  -- Set 'omnifunc' for LSP completion only when needed.
  local on_attach = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
  end
  Config.new_autocmd("LspAttach", nil, on_attach, "Set 'omnifunc'")

  vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

now_if_args(function()
  require("mini.files").setup { windows = { preview = true } }

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesWindowUpdate",
    callback = function(args)
      local win_id = args.data.win_id
      local config = vim.api.nvim_win_get_config(win_id)
      config.height = math.floor(0.3 * vim.o.lines)

      local has_border = config.border and config.border ~= "none" and config.border ~= ""
      local buf_id = vim.api.nvim_win_get_buf(win_id)
      local line_count = vim.api.nvim_buf_line_count(buf_id)
      if has_border and line_count > config.height then
        config.footer = string.format(" %d/%d ", vim.api.nvim_win_get_cursor(win_id)[1], line_count)
        config.footer_pos = "right"
      elseif has_border then
        config.footer = ""
        config.footer_pos = "right"
      end

      vim.api.nvim_win_set_config(win_id, config)
    end,
  })
end)

now_if_args(function()
  require("mini.misc").setup()
  MiniMisc.setup_auto_root()
  MiniMisc.setup_restore_cursor()
  MiniMisc.setup_termbg_sync()
end)

later(function()
  require("mini.extra").setup()
end)

later(function()
  local ai = require "mini.ai"
  ai.setup {
    custom_textobjects = {
      B = MiniExtra.gen_ai_spec.buffer(),
      F = ai.gen_spec.treesitter { a = "@function.outer", i = "@function.inner" },
    },
    search_method = "cover",
  }
end)

later(function()
  require("mini.bracketed").setup()
end)

later(function()
  require("mini.bufremove").setup()
end)

later(function()
  require("mini.cmdline").setup()
end)

later(function()
  require("mini.comment").setup()
end)

later(function()
  require("mini.cursorword").setup()
  local ft = { "help", "mason", "notify", "term" }
  local f = function(args)
    vim.b[args.buf].minicursorword_disable = true
  end
  Config.new_autocmd("FileType", ft, f, "disable cursorword for some filetypes")
end)

later(function()
  require("mini.diff").setup {
    view = {
      style = "sign",
      signs = { add = "┃", change = "┃", delete = "_" },
    },
  }
end)

later(function()
  require("mini.git").setup()
end)

later(function()
  local hipatterns = require "mini.hipatterns"
  local hi_words = MiniExtra.gen_highlighter.words
  hipatterns.setup {
    highlighters = {
      fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
      hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
      todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
      note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),

      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  }
end)

later(function()
  require("mini.indentscope").setup {
    draw = {
      animation = require("mini.indentscope").gen_animation.none(),
    },
    options = { try_as_border = true },
    symbol = "│",
  }

  local ft = { "help", "mason", "notify", "term" }
  local f = function(args)
    vim.b[args.buf].miniindentscope_disable = true
  end
  Config.new_autocmd("FileType", ft, f, "disable indentscope for some filetypes")
  Config.new_autocmd("TermOpen", "*", f, "disable indentscope for terminal buffers")
end)

later(function()
  require("mini.jump").setup()
end)

later(function()
  require("mini.jump2d").setup()
end)

later(function()
  require("mini.keymap").setup()
  MiniKeymap.map_multistep("i", "<Tab>", {
    {
      condition = function()
        return vim.lsp.inline_completion.get() ~= nil
      end,
      action = function()
        return "<Tab>"
      end,
    },
  })
  MiniKeymap.map_multistep("i", "<CR>", { "minipairs_cr" })
  MiniKeymap.map_multistep("i", "<BS>", { "minipairs_bs" })
end)

later(function()
  local map = require "mini.map"
  map.setup {
    symbols = { encode = map.gen_encode_symbols.dot "4x2" },
    integrations = {
      map.gen_integration.builtin_search(),
      map.gen_integration.diff(),
      map.gen_integration.diagnostic(),
    },
  }

  for _, key in ipairs { "n", "N", "*", "#" } do
    local rhs = key .. "zv" .. "<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>"
    vim.keymap.set("n", key, rhs)
  end
end)

later(function()
  require("mini.move").setup {
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
  }
end)

later(function()
  require("mini.operators").setup()

  vim.keymap.set("n", "(", "gxiagxila", { remap = true, desc = "Swap arg left" })
  vim.keymap.set("n", ")", "gxiagxina", { remap = true, desc = "Swap arg right" })
end)

later(function()
  require("mini.pairs").setup { modes = { command = true } }
end)

later(function()
  require("mini.pick").setup {
    window = {
      config = function()
        local height = math.floor(0.3 * vim.o.lines)
        local width = math.floor(0.45 * vim.o.columns)
        return {
          anchor = "NW",
          height = height,
          width = width,
          row = math.floor((vim.o.lines - height) / 2),
          col = math.floor((vim.o.columns - width) / 2),
        }
      end,
    },
  }
end)

later(function()
  require("mini.splitjoin").setup()
end)

later(function()
  local lang_patterns = {
    markdown_inline = { "markdown.json" },
  }

  local snippets = require "mini.snippets"
  local config_path = vim.fn.stdpath "config"
  snippets.setup {
    snippets = {
      snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
      snippets.gen_loader.from_lang { lang_patterns = lang_patterns },
    },
  }

  MiniSnippets.start_lsp_server()
end)

later(function()
  require("mini.surround").setup()
end)

later(function()
  require("mini.trailspace").setup()
end)

later(function()
  local miniclue = require "mini.clue"

  miniclue.setup {
    clues = {
      Config.leader_group_clues,
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.windows { submode_resize = true },
      miniclue.gen_clues.z(),
    },
    -- stylua: ignore start
    triggers = {
      { mode = { 'n', 'x' }, keys = '<Leader>' }, -- Leader triggers
      { mode = 'n',          keys = '\\' },       -- mini.basics
      { mode = { 'n', 'x' }, keys = '[' },        -- mini.bracketed
      { mode = { 'n', 'x' }, keys = ']' },
      { mode = 'i',          keys = '<C-x>' },    -- Built-in completion
      { mode = { 'n', 'x' }, keys = 'g' },        -- `g` key
      { mode = { 'n', 'x' }, keys = "'" },        -- Marks
      { mode = { 'n', 'x' }, keys = '`' },
      { mode = { 'n', 'x' }, keys = '"' },        -- Registers
      { mode = { 'i', 'c' }, keys = '<C-r>' },
      { mode = 'n',          keys = '<C-w>' },    -- Window commands
      { mode = { 'n', 'x' }, keys = 's' },        -- `s` key (mini.surround, etc.)
      { mode = { 'n', 'x' }, keys = 'z' },        -- `z` key
      -- stylua: ignore end
    },
    window = {
      delay = 300,
    },
  }
end)
