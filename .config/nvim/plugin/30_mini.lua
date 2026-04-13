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

now(function() require('mini.tabline').setup() end)

now(function() require('mini.statusline').setup() end)

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
  require("mini.cmdline").setup {
    autocomplete = {
      enable = false,
    },
  }
end)

later(function()
  require("mini.comment").setup()
end)

later(function()
  require("mini.cursorword").setup()

  local disabled_filetypes = { "dashboard", "help", "mason", "notify" }
  local disable_cursorword = function(args) vim.b[args.buf].minicursorword_disable = true end
  Config.new_autocmd("FileType", disabled_filetypes, disable_cursorword, "disable cursorword for some filetypes")
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
end)

later(function()
  require("mini.jump").setup()
end)

later(function()
  require("mini.jump2d").setup()
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
  require("mini.splitjoin").setup()
end)

later(function()
  require("mini.surround").setup()
end)

later(function()
  require("mini.trailspace").setup()
end)

later(function()
  -- Disable indent scope and cursorword in some modes and filetypes
  local disabled_filetypes = { "snacks_dashboard", "help", "mason", "notify", "term" }
  local disable_indent_cursorword = function(args)
    local b = vim.b[args.buf]
    b.miniindentscope_disable = true
    b.minicursorword_disable = true
  end
  Config.new_autocmd("FileType", disabled_filetypes, disable_indent_cursorword, "disable indentscope for some filetypes")
  Config.new_autocmd("TermOpen", "*", disable_indent_cursorword, "disable indentscope for terminal buffers")
end)
