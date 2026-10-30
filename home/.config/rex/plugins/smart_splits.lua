-- smart_splits: the Rex side of smart-splits.nvim.
--
-- Neovim runs the `rawnly/smart-splits-backend-rex` backend, which moves Rex
-- focus and resizes Rex panes when the cursor is at the edge of the editor.
-- This module does the opposite: it binds the keys in Rex and lets them through
-- to (n)vim when it is the foreground program, so Neovim decides first.
--
-- Based on rex/lua/smart-splits-rex/init.lua from that repository, without the
-- Rex Plugin Manager.
--
-- Usage:
--   require("plugins.smart_splits").setup {
--     keys = { focus = "ctrl", resize = "alt" }, -- modifier + h/j/k/l, false skips
--     resize_amount = 3,
--     passthrough = { "nvim", "vim" },
--   }
--
-- Actions, for the palette, the CLI or your own bindings:
--   smart_splits_focus  direction=<left|right|up|down> key=?
--   smart_splits_resize direction=<left|right|up|down> key=? amount=?
-- With `key`, the action sends that key to a passthrough program instead of
-- acting on Rex. Without it, the action always acts on Rex.
--
-- Resizing a Rex pane goes through the app's `pane.resize` action, so it needs
-- an app client. From the CLI that means Remote Control must be on.

local M = {}

local TERMINAL = "com.superlogical.terminal"

---@type table<string, string>
local KEYS = { h = "left", j = "down", k = "up", l = "right" }

local DIRECTION = { type = "string", enum = { "left", "right", "up", "down" } }

---@class smart_splits.Keys
---@field focus? string|false Modifier for focus keys, such as "ctrl". `false` binds nothing.
---@field resize? string|false Modifier for resize keys, such as "alt". `false` binds nothing.

---@class smart_splits.Options
---@field keys? smart_splits.Keys
---@field resize_amount? integer Cells per resize step. Defaults to 3.
---@field passthrough? string[] Foreground programs that get the keys instead of Rex.

---@class smart_splits.Config
---@field keys smart_splits.Keys
---@field resize_amount integer
---@field passthrough table<string, boolean>

local defaults = {
  -- Resize keys are off by default: binding alt+h/j/k/l in Rex takes them from
  -- every other program. Neovim gets them anyway when Rex leaves them unbound.
  keys = { focus = "ctrl", resize = false },
  resize_amount = 3,
  passthrough = { "nvim", "vim", "nvimdiff", "vimdiff", "view" },
}

---@type smart_splits.Config
local cfg

---@param list string[]
---@return table<string, boolean>
local function set(list)
  local out = {}
  for _, name in ipairs(list) do
    out[name] = true
  end
  return out
end

---@param opts? smart_splits.Options
---@return smart_splits.Config
local function resolve(opts)
  opts = opts or {}
  local keys = opts.keys or {}
  local function pick(value, fallback)
    if value == nil then
      return fallback
    end
    return value
  end
  return {
    keys = {
      focus = pick(keys.focus, defaults.keys.focus),
      resize = pick(keys.resize, defaults.keys.resize),
    },
    resize_amount = opts.resize_amount or defaults.resize_amount,
    passthrough = set(opts.passthrough or defaults.passthrough),
  }
end

-- Whether the block runs a passthrough program in the foreground. Anything we
-- can't tell, such as a block that isn't a terminal, counts as "no", so the key
-- still moves between Rex panes.
---@param block_id? string
---@return boolean
local function passthrough(block_id)
  if not block_id then
    return false
  end
  local p = rex.block.call(TERMINAL, "process", { block_id = block_id })
  local fg = p and p.foreground
  if not fg then
    return false
  end
  -- `name` is not always the executable's name, so check argv0 as well.
  local argv0 = (fg.argv0 or ""):match "[^/]*$"
  return cfg.passthrough[fg.name or ""] == true or cfg.passthrough[argv0] == true
end

---@param direction string
---@return string? err
local function focus(direction)
  local _, err = rex.session.focus_direction { direction = direction }
  return err
end

-- In an action: send `key` to the passthrough program, if there is one.
---@return boolean sent
local function forward(ctx, key)
  if not key or key == "" or not passthrough(ctx.block_id) then
    return false
  end
  rex.client.queue("pane.send_key", { key = key })
  return true
end

---@param opts? smart_splits.Options
function M.setup(opts)
  cfg = resolve(opts)

  rex.action {
    name = "smart_splits_focus",
    title = "Smart Splits: Focus Pane",
    description = "Move focus to the pane in a direction, or send `key` to (n)vim when it is in front.",
    category = "Panes",
    args = {
      type = "object",
      required = { "direction" },
      properties = { direction = DIRECTION, key = { type = "string" } },
      additionalProperties = false,
    },
    run = function(ctx, args)
      if forward(ctx, args.key) then
        return
      end
      local err = focus(args.direction)
      if err ~= nil then
        error("smart_splits: " .. tostring(err), 0)
      end
    end,
  }

  rex.action {
    name = "smart_splits_resize",
    title = "Smart Splits: Resize Pane",
    description = "Resize the pane in a direction, or send `key` to (n)vim when it is in front.",
    category = "Panes",
    repeats = true,
    args = {
      type = "object",
      required = { "direction" },
      properties = {
        direction = DIRECTION,
        key = { type = "string" },
        amount = { type = "integer", minimum = 1 },
      },
      additionalProperties = false,
    },
    run = function(ctx, args)
      if forward(ctx, args.key) then
        return
      end
      rex.client.queue("pane.resize", { direction = args.direction, amount = args.amount or cfg.resize_amount })
    end,
  }

  for letter, direction in pairs(KEYS) do
    if cfg.keys.focus then
      -- A function, not the action: returning false hands the original key to
      -- the terminal, so Neovim gets it as typed, with no client round trip.
      rex.bind(cfg.keys.focus .. "+" .. letter, function(ctx)
        if passthrough(ctx.block_id) then
          return false
        end
        local err = focus(direction)
        if err ~= nil then
          rex.log("warn", "smart_splits: " .. tostring(err))
        end
        return true
      end)
    end
    if cfg.keys.resize then
      -- `pane.resize` is a client action, and only actions can queue those, so
      -- this goes through the action and forwards the key itself.
      local key = cfg.keys.resize .. "+" .. letter
      rex.bind(key, "smart_splits_resize", { direction = direction, key = key })
    end
  end
end

return M
