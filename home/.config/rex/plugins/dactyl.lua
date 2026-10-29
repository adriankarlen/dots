-- dactyl: a sesh/yeet-style session picker for Rex.
--
-- Lists open Rex sessions, configured workspaces and zoxide directories in a
-- floating `gum filter` pane. Picking an entry switches to that session, or
-- creates it in the right directory first.
--
-- Usage:
--   require("plugins.dactyl").setup{
--     keys = { pick = "cmd+k", last = "cmd+shift+k" },
--     blacklist = { "^scratch$" },
--     workspaces = { { name = "dots", path = "~/dots", startup = "nvim" } },
--     rules = { { path_glob = "~/repos/**", startup = "nvim" } },
--   }
--
-- Switching sessions from the picker needs Remote Control turned on in
-- Rex.app (Settings > Rex Server).

local M = {}

local HOME = os.getenv "HOME" or ""
local SHELL_FLAVOR = "com.superlogical.terminal.shell"
local STATE_DIR = (os.getenv "XDG_STATE_HOME" or (HOME .. "/.local/state")) .. "/dactyl"
local LAST_FILE = STATE_DIR .. "/last"

-- Nerd Font icons, same as yeet: session, workspace, directory.
local ICONS = {
  session = "\27[36m\239\146\137\27[39m",
  workspace = "\27[90m\238\152\149\27[39m",
  dir = "\27[36m\239\132\148\27[39m",
}

---@class dactyl.Keys
---@field pick? string|false Opens the picker. `false` leaves it unbound.
---@field last? string|false Switches to the last session. `false` leaves it unbound.

---@class dactyl.Workspace
---@field name string
---@field path? string Defaults to `~`.
---@field startup? string Typed into the new session's shell.

---@class dactyl.Rule
---@field path_glob string Such as `~/repos/**`.
---@field startup? string

---@class dactyl.Config
---@field keys dactyl.Keys
---@field blacklist string[] Lua patterns matched against session and workspace names.
---@field workspaces dactyl.Workspace[]
---@field rules dactyl.Rule[]
---@field dir_length integer Folder levels used to name sessions outside git repos.
---@field icons boolean
---@field zoxide boolean
---@field bounds number[] Floating pane `{ x, y, w, h }` as fractions of the window.
---@field placeholder string
---@field prompt string
---@field label string Name shown in the floating pane's header.
---@field gum_setup string|false Shell run before gum, e.g. to load a GUM_* theme.

---@class dactyl.Options
---@field keys? dactyl.Keys
---@field blacklist? string[]
---@field workspaces? dactyl.Workspace[]
---@field rules? dactyl.Rule[]
---@field dir_length? integer
---@field icons? boolean
---@field zoxide? boolean
---@field bounds? number[]
---@field placeholder? string
---@field prompt? string
---@field label? string
---@field gum_setup? string|false

---@type dactyl.Config
local defaults = {
  keys = { pick = "cmd+k", last = "cmd+shift+k" },
  -- Lua patterns matched against session and workspace names.
  blacklist = {},
  -- { name = "dots", path = "~/dots", startup = "nvim" }
  workspaces = {},
  -- { path_glob = "~/repos/**", startup = "nvim" }
  rules = {},
  -- Folder levels used to name sessions outside git repos.
  dir_length = 1,
  icons = true,
  zoxide = true,
  -- Floating pane: { x, y, w, h } as fractions of the window.
  bounds = { 0.3, 0.25, 0.4, 0.45 },
  placeholder = "Pick a session",
  prompt = " ",
  -- Name shown in the floating pane's header.
  label = "dactyl",
  -- Run before gum, e.g. to load a GUM_* theme. Set to false to skip.
  gum_setup = "command -v gum-rose-pine >/dev/null && source gum-rose-pine",
}

---@type dactyl.Config
local cfg = defaults

-- Helpers -------------------------------------------------------------------

local function merge(base, over)
  local out = {}
  for k, v in pairs(base) do
    out[k] = v
  end
  for k, v in pairs(over or {}) do
    out[k] = v
  end
  return out
end

local function expand(path)
  if path == "~" then
    return HOME
  end
  if path:sub(1, 2) == "~/" then
    return HOME .. path:sub(2)
  end
  return path
end

local function abbreviate(path)
  if path == HOME then
    return "~"
  end
  if HOME ~= "" and path:sub(1, #HOME + 1) == HOME .. "/" then
    return "~" .. path:sub(#HOME + 1)
  end
  return path
end

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- rex.exec looks programs up in the server's PATH, which may not include
-- Homebrew. Retry there when the program can't be found.
local function exec(argv, opts)
  local r, err = rex.exec(argv, opts)
  if r == nil and not argv[1]:find "/" then
    for _, dir in ipairs { "/opt/homebrew/bin", "/usr/local/bin" } do
      local retry = { dir .. "/" .. argv[1] }
      for i = 2, #argv do
        retry[i] = argv[i]
      end
      r, err = rex.exec(retry, opts)
      if r ~= nil then
        break
      end
    end
  end
  return r, err
end

local function blacklisted(name)
  for _, pat in ipairs(cfg.blacklist) do
    if name:find(pat) then
      return true
    end
  end
  return false
end

-- Turn a glob such as ~/repos/** into an anchored Lua pattern.
local function glob_to_pattern(glob)
  local p = expand(glob):gsub("[%^%$%(%)%%%.%[%]%+%-%?]", "%%%0")
  p = p:gsub("%*%*", "\1"):gsub("%*", "[^/]*"):gsub("\1", ".*")
  return "^" .. p .. "$"
end

local function startup_for(path)
  for _, rule in ipairs(cfg.rules) do
    if rule.path_glob and path:find(glob_to_pattern(rule.path_glob)) then
      return rule.startup
    end
  end
  return nil
end

local function read_last()
  local f = io.open(LAST_FILE, "r")
  if not f then
    return nil
  end
  local id = f:read "*l"
  f:close()
  return id
end

local function write_last(id)
  if not id then
    return
  end
  exec { "mkdir", "-p", STATE_DIR }
  local f = io.open(LAST_FILE, "w")
  if f then
    f:write(id, "\n")
    f:close()
  end
end

local function list_sessions()
  local r, err = rex.call "session.list"
  if r == nil then
    error("dactyl: " .. tostring(err), 0)
  end
  return r.sessions or {}
end

local function find_session(sessions, label)
  for _, s in ipairs(sessions) do
    if s.label == label then
      return s
    end
  end
  return nil
end

local function find_workspace(name)
  for _, ws in ipairs(cfg.workspaces) do
    if ws.name == name then
      return ws
    end
  end
  return nil
end

-- Name a directory the way yeet does: git remote repo name, then git root
-- folder name, then the last `dir_length` folders.
local function name_for(path)
  local root = exec { "git", "-C", path, "rev-parse", "--show-toplevel" }
  if root and root.ok and trim(root.stdout) ~= "" then
    local remote = exec { "git", "-C", path, "config", "--get", "remote.origin.url" }
    if remote and remote.ok and trim(remote.stdout) ~= "" then
      local url = trim(remote.stdout):gsub("%.git$", ""):gsub("/+$", "")
      local name = url:match "([^/:]+)$" or url
      return (name:gsub("[^%w%._%-]+", "-"))
    end
    return trim(root.stdout):match "([^/]+)$"
  end

  local parts = {}
  for part in path:gmatch "[^/]+" do
    parts[#parts + 1] = part
  end
  if #parts == 0 then
    return path
  end
  local n = math.min(math.max(cfg.dir_length, 1), #parts)
  return table.concat(parts, "/", #parts - n + 1)
end

-- Picker items --------------------------------------------------------------

local function build_items(current_id)
  local items, seen_names, seen_paths = {}, {}, {}
  local function add(kind, text)
    items[#items + 1] = cfg.icons and (ICONS[kind] .. " " .. text) or text
  end

  -- Open sessions: the last one first, the current one left out.
  local sessions, last = {}, read_last()
  for _, s in ipairs(list_sessions()) do
    if s.session_id == last then
      table.insert(sessions, 1, s)
    else
      sessions[#sessions + 1] = s
    end
  end
  for _, s in ipairs(sessions) do
    seen_names[s.label] = true
    if s.session_id ~= current_id and not blacklisted(s.label) then
      add("session", s.label)
    end
  end

  for _, ws in ipairs(cfg.workspaces) do
    if ws.path then
      seen_paths[expand(ws.path)] = true
    end
    if not seen_names[ws.name] and not blacklisted(ws.name) then
      seen_names[ws.name] = true
      add("workspace", ws.name)
    end
  end

  if cfg.zoxide then
    local z = exec { "zoxide", "query", "--list" }
    if z and z.ok then
      for path in z.stdout:gmatch "[^\n]+" do
        if not seen_paths[path] then
          seen_paths[path] = true
          add("dir", abbreviate(path))
        end
      end
    end
  end

  return items
end

-- Strip colors and the icon from a picked line.
local function parse_target(line)
  local s = trim(line:gsub("\27%[[%d;]*m", ""))
  if cfg.icons then
    s = s:match "^[^%s]+%s+(.+)$" or s
  end
  return trim(s)
end

-- Actions -------------------------------------------------------------------

local function pick(ctx)
  local items = build_items(ctx.session_id)
  if #items == 0 then
    return
  end

  local list = os.tmpname()
  local f = assert(io.open(list, "w"))
  f:write(table.concat(items, "\n"), "\n")
  f:close()

  local script = [[
list="$1" client="$2" from="$3" placeholder="$4" setup="$5" prompt="$6"
# Clear the arguments so a sourced theme script doesn't inherit them.
set --
printf '\033]2;dactyl\007'
[ -n "$setup" ] && eval "$setup" >/dev/null 2>&1
choice=$(gum filter --limit 1 --no-sort --fuzzy --no-strip-ansi \
  --placeholder "$placeholder" --prompt "$prompt" < "$list")
status=$?
rm -f "$list"
[ $status -eq 0 ] && [ -n "$choice" ] || exit 0
if [ -n "$client" ]; then
  rex -C "$client" do dactyl_connect target="$choice" from="$from" >/dev/null
else
  rex do dactyl_connect target="$choice" from="$from" >/dev/null
fi || { echo "dactyl: could not connect to $choice"; read -r -n 1; }
]]

  local b = cfg.bounds
  local _, err = rex.session.new_layer {
    bounds = { b[1], b[2], b[3], b[4] },
    focus = true,
    layout = {
      block = {
        flavor = SHELL_FLAVOR,
        label = cfg.label,
        options = {
          -- Re-exec bash under the label as argv[0].
          command = {
            "bash",
            "-c",
            'exec -a "$0" bash -c "$@"',
            cfg.label,
            script,
            cfg.label,
            list,
            ctx.client_id or "",
            ctx.session_id or "",
            cfg.placeholder,
            cfg.gum_setup or "",
            cfg.prompt,
          },
        },
      },
    },
  }
  if err ~= nil then
    os.remove(list)
    error("dactyl: " .. tostring(err), 0)
  end
end

local function select_session(id, from)
  if from and from ~= id then
    write_last(from)
  end
  rex.client.queue("session.select", { session_id = id })
  return { session_id = id }
end

local function connect(ctx, args)
  local target = parse_target(args.target or "")
  if target == "" then
    error("dactyl: no target", 0)
  end
  local from = args.from or ctx.session_id
  local sessions = list_sessions()

  -- An open session.
  local s = find_session(sessions, target)
  if s then
    return select_session(s.session_id, from)
  end

  -- A workspace or a directory.
  local path, name, startup
  local ws = find_workspace(target)
  if ws then
    path = expand(ws.path or "~")
    name = ws.name
    startup = ws.startup or startup_for(path)
  else
    path = expand(target)
    name = name_for(path)
    startup = startup_for(path)
  end

  s = find_session(sessions, name)
  if s then
    exec { "zoxide", "add", path }
    return select_session(s.session_id, from)
  end

  local options = { cwd = path }
  if startup and startup ~= "" then
    options.initial_input = startup .. "\n"
  end

  local created, err = rex.call("session.create", {
    label = name,
    initial_windows = {
      { layout = rex.layout.block { flavor = SHELL_FLAVOR, options = options } },
    },
  })
  if created == nil then
    error("dactyl: " .. tostring(err), 0)
  end

  exec { "zoxide", "add", path }
  return select_session(created.session_id, from)
end

local function last(ctx)
  local id = read_last()
  if not id then
    return
  end
  for _, s in ipairs(list_sessions()) do
    if s.session_id == id then
      return select_session(id, ctx.session_id)
    end
  end
end

-- Setup ---------------------------------------------------------------------

---@param opts? dactyl.Options
function M.setup(opts)
  cfg = merge(defaults, opts)
  cfg.keys = merge(defaults.keys, opts and opts.keys)

  rex.action {
    name = "dactyl",
    title = "Dactyl: Pick Session…",
    description = "Pick an open session, workspace or zoxide directory.",
    category = "Sessions",
    keywords = "sesh yeet zoxide session switch",
    run = pick,
  }

  rex.action {
    name = "dactyl_connect",
    title = "Dactyl: Connect",
    description = "Switch to a session, or create it for a workspace or directory.",
    category = "Sessions",
    args = { target = "string", from = "string?" },
    run = connect,
  }

  rex.action {
    name = "dactyl_last",
    title = "Dactyl: Last Session",
    description = "Switch back to the session you came from.",
    category = "Sessions",
    run = last,
  }

  if cfg.keys.pick then
    rex.bind(cfg.keys.pick, "dactyl")
  end
  if cfg.keys.last then
    rex.bind(cfg.keys.last, "dactyl_last")
  end
end

return M
