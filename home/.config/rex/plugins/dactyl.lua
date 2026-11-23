-- dactyl: a sesh/yeet-style session picker for Rex.
--
-- Lists open Rex sessions, configured workspaces and zoxide directories in
-- Rex's own picker (rex.ui.pick, in the command palette). Picking an entry
-- switches to that session, or creates it in the right directory first.
-- Typing text that matches no entry opens it as a path, or as the best
-- zoxide match for it.
--
-- A second picker lists the coding agents running in every session, with the
-- status they report through the Program Status Protocol (OSC 7501). Picking
-- one switches to its session and focuses its pane. Agents that don't report
-- a status are found by their process name and shown as `unknown`.
--
-- Usage:
--   require("plugins.dactyl").setup{
--     keys = { pick = "cmd+k", last = "cmd+shift+k", agents = "cmd+j" },
--     blacklist = { "^scratch$" },
--     workspaces = { { name = "dots", path = "~/dots", startup = "nvim" } },
--     rules = { { path_glob = "~/repos/**", startup = "nvim" } },
--     agents = { processes = { "claude", "codex" } },
--   }
--
-- The pickers need a Rex server and app with control API revision 17 or
-- later. Both actions also take their answer as an argument, so scripts can
-- run them with nobody there to pick:
--   rex do dactyl target=~/repos/rex
--   rex do dactyl_agents block_id=block:…

local M = {}

local HOME = os.getenv "HOME" or ""
local TERMINAL = "com.superlogical.terminal"
local SHELL_FLAVOR = TERMINAL .. ".shell"
local STATE_DIR = (os.getenv "XDG_STATE_HOME" or (HOME .. "/.local/state")) .. "/dactyl"
local LAST_FILE = STATE_DIR .. "/last"

-- Most rows rex.ui.pick shows.
local MAX_ITEMS = 2000

---@alias dactyl.Icon "document"|"folder"|"branch"|"terminal"|"code"|"server"|"database"|"package"|"globe"|"link"|"person"|"tag"|"clock"|"star"|"gear"|"plus"

---@class dactyl.Keys
---@field pick? string|false Opens the session picker. `false` leaves it unbound.
---@field last? string|false Switches to the last session. `false` leaves it unbound.
---@field agents? string|false Opens the agent picker. `false` leaves it unbound.

---@class dactyl.Agents
---@field processes string[] Process names counted as agents when they report no status.
---@field title string
---@field placeholder string
---@field confirm? string Label of the row that focuses the picked agent.
---@field icons table<string, dactyl.Icon> Rex icon per state (`blocked`, `error`, `done`, `working`, `idle`, `unknown`).

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
---@field agents dactyl.Agents
---@field dir_length integer Folder levels used to name sessions outside git repos.
---@field icons boolean Show icons in the pickers.
---@field zoxide boolean
---@field title string
---@field placeholder string
---@field confirm? string Label of the row that switches to the picked entry.

---@class dactyl.Options
---@field keys? dactyl.Keys
---@field blacklist? string[]
---@field workspaces? dactyl.Workspace[]
---@field rules? dactyl.Rule[]
---@field agents? dactyl.Agents
---@field dir_length? integer
---@field icons? boolean
---@field zoxide? boolean
---@field title? string
---@field placeholder? string
---@field confirm? string

---@type dactyl.Config
local defaults = {
  keys = { pick = "cmd+k", last = "cmd+shift+k", agents = "cmd+j" },
  -- Lua patterns matched against session and workspace names.
  blacklist = {},
  -- { name = "dots", path = "~/dots", startup = "nvim" }
  workspaces = {},
  -- { path_glob = "~/repos/**", startup = "nvim" }
  rules = {},
  agents = {
    -- Foreground process names counted as agents when they report no status.
    processes = { "claude", "codex", "opencode", "gemini", "aider", "amp" },
    title = "Pick an agent",
    placeholder = "Filter agents",
    icons = {
      blocked = "person",
      error = "terminal",
      done = "star",
      working = "clock",
      idle = "terminal",
      unknown = "terminal",
    },
  },
  -- Folder levels used to name sessions outside git repos.
  dir_length = 1,
  icons = true,
  zoxide = true,
  title = "Pick a session",
  placeholder = "Filter sessions, workspaces and folders",
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

local function one_line(s)
  return trim((s or ""):gsub("%c", " "))
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

local function is_dir(path)
  local r = exec { "test", "-d", path }
  return r ~= nil and r.ok
end

local function icon(name)
  return cfg.icons and name or nil
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

local function find_session(sessions, key, value)
  for _, s in ipairs(sessions) do
    if s[key] == value then
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

-- Ask with rex.ui.pick. Returns the answer, or nil when there is none, and
-- logs why unless the person closed the picker.
local function ask(prompt)
  if not (rex.ui and rex.ui.pick) then
    error("dactyl: this Rex server has no rex.ui.pick. Update Rex and restart its server.", 0)
  end
  local answer, why, detail = rex.ui.pick(prompt)
  if answer == nil and why ~= "cancelled" then
    rex.log("warn", "dactyl: no answer from the picker: " .. tostring(why) .. (detail and (" " .. detail) or ""))
  end
  return answer
end

-- Switching -----------------------------------------------------------------

local function select_session(id, from, window_id)
  if from and from ~= id then
    write_last(from)
  end
  rex.client.queue("session.select", { session_id = id, window_id = window_id })
  return { session_id = id, window_id = window_id }
end

-- Switch to the session named `name`, or create it in `path`.
local function open_path(sessions, name, path, startup, from)
  local s = find_session(sessions, "label", name)
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

local function open_workspace(sessions, ws, from)
  local path = expand(ws.path or "~")
  return open_path(sessions, ws.name, path, ws.startup or startup_for(path), from)
end

local function open_dir(sessions, path, from)
  return open_path(sessions, name_for(path), path, startup_for(path), from)
end

-- Open typed text: a session or workspace name, a directory, or the best
-- zoxide match for it.
local function open_text(sessions, text, from)
  text = trim(text)
  if text == "" then
    return nil
  end

  local s = find_session(sessions, "label", text)
  if s then
    return select_session(s.session_id, from)
  end
  local ws = find_workspace(text)
  if ws then
    return open_workspace(sessions, ws, from)
  end

  local path = expand(text):gsub("(.)/+$", "%1")
  if path:sub(1, 1) == "/" and is_dir(path) then
    return open_dir(sessions, path, from)
  end
  if cfg.zoxide then
    local z = exec { "zoxide", "query", "--", text }
    if z and z.ok and trim(z.stdout) ~= "" then
      return open_dir(sessions, trim(z.stdout), from)
    end
  end

  rex.log("warn", "dactyl: no session, workspace or folder matches " .. text)
  return nil
end

-- Session picker ------------------------------------------------------------

-- Item IDs start with their kind, so a picked ID says what to open.
local function build_items(sessions, current_id)
  local items, seen_names, seen_paths = {}, {}, {}
  local function add(item)
    if #items < MAX_ITEMS then
      items[#items + 1] = item
    end
  end

  -- Open sessions: the last one first, the current one left out.
  local ordered, last = {}, read_last()
  for _, s in ipairs(sessions) do
    if s.session_id == last then
      table.insert(ordered, 1, s)
    else
      ordered[#ordered + 1] = s
    end
  end
  for _, s in ipairs(ordered) do
    seen_names[s.label] = true
    if s.session_id ~= current_id and not blacklisted(s.label) then
      local ws = find_workspace(s.label)
      add {
        id = "s:" .. s.session_id,
        title = s.label,
        subtitle = ws and abbreviate(expand(ws.path or "~")) or nil,
        icon = icon "terminal",
        detail = s.session_id == last and "last" or "open",
      }
    end
  end

  for _, ws in ipairs(cfg.workspaces) do
    local path = expand(ws.path or "~")
    seen_paths[path] = true
    if not seen_names[ws.name] and not blacklisted(ws.name) then
      seen_names[ws.name] = true
      add {
        id = "w:" .. ws.name,
        title = ws.name,
        subtitle = abbreviate(path),
        icon = icon "star",
        detail = "workspace",
      }
    end
  end

  if cfg.zoxide then
    local z = exec { "zoxide", "query", "--list" }
    if z and z.ok then
      for path in z.stdout:gmatch "[^\n]+" do
        if not seen_paths[path] then
          seen_paths[path] = true
          add { id = "d:" .. path, title = abbreviate(path), icon = icon "folder" }
        end
      end
    end
  end

  return items
end

local function pick(ctx, args)
  local from = ctx.session_id
  local sessions = list_sessions()
  if args and args.target then
    return open_text(sessions, args.target, from)
  end

  local answer = ask {
    title = cfg.title,
    placeholder = cfg.placeholder,
    confirm = cfg.confirm,
    allow_other = true,
    items = build_items(sessions, from),
  }
  if answer == nil then
    return nil
  end
  if type(answer) == "table" then
    return open_text(sessions, answer.text or "", from)
  end

  local kind, value = answer:match "^(%a):(.*)$"
  if kind == "s" then
    return select_session(value, from)
  elseif kind == "w" then
    local ws = find_workspace(value)
    return ws and open_workspace(sessions, ws, from)
  elseif kind == "d" then
    return open_dir(sessions, value, from)
  end
  return nil
end

local function last(ctx)
  local id = read_last()
  if id and find_session(list_sessions(), "session_id", id) then
    return select_session(id, ctx.session_id)
  end
end

-- Agents --------------------------------------------------------------------

-- Ordered by how much they need you. A state Rex adds later counts as idle.
local AGENT_RANK = { blocked = 1, error = 2, done = 3, working = 4, idle = 5, unknown = 6 }

-- States that outlive the program that reported them. Rex drops `working`
-- and `blocked` itself when the program exits.
local STICKY_STATES = { done = true, error = true, idle = true }

-- rex.call, but attach to every session first if the server asks for it.
-- Calls into another session fail until the connection is attached to it.
local function server_caller()
  local attached = false
  return function(method, args)
    local r, err = rex.call(method, args)
    if r == nil and not attached and tostring(err):find("not attached", 1, true) then
      attached = true
      rex.call("session.attach_all", { event_scope = "session" })
      r, err = rex.call(method, args)
    end
    return r, err
  end
end

-- The configured agent name the foreground process runs as, if any.
local function agent_process(fg)
  if not fg then
    return nil
  end
  for _, cand in ipairs { fg.argv0, fg.name } do
    local name = cand and cand:gsub("^%-", ""):match "[^/]*$"
    for _, p in ipairs(cfg.agents.processes) do
      if name == p then
        return name
      end
    end
  end
  return nil
end

-- A record still belongs to the running program if it reported while that
-- program was in the foreground.
local function live(record, fg)
  if not STICKY_STATES[record.state] or not record.owner then
    return true
  end
  return fg ~= nil and record.owner.pid == fg.pid and record.owner.name == fg.name
end

-- The most urgent live status record of a terminal.
local function agent_status(records, fg)
  local best
  for _, r in ipairs(records or {}) do
    if live(r, fg) then
      local state = AGENT_RANK[r.state] and r.state or "idle"
      if not best or AGENT_RANK[state] < AGENT_RANK[best.state] then
        best = {
          state = state,
          app = r.effective_app or r.app,
          msg = r.msg,
          updated_at = r.updated_at,
        }
      end
    end
  end
  return best
end

-- Every agent in every session but the pane the picker was opened from,
-- the most urgent first.
local function list_agents(current_block)
  local call = server_caller()
  local agents = {}
  for order, s in ipairs(list_sessions()) do
    local tabs = {}
    local view = call("session.view", { session_id = s.session_id })
    for i, w in ipairs(view and view.windows or {}) do
      -- Rex names unnamed tabs "Window <id suffix>". Only keep real names.
      local label = w.label and not w.label:find "^Window %x+$" and one_line(w.label) or nil
      tabs[w.window_id] = { index = i, label = label ~= "" and label or nil }
    end

    local blocks = call("session.list_blocks", { session_id = s.session_id })
    for _, b in ipairs(blocks and blocks.blocks or {}) do
      if b.creator_name == TERMINAL and b.placement == "placed" and b.window_id and b.block_id ~= current_block then
        local function method(name)
          return call("block.method", { session_id = s.session_id, block_id = b.block_id, method = name })
        end

        local proc = method "process"
        local fg = proc and proc.foreground
        local status = method "program_status"
        local agent = agent_status(status and status.records, fg)
        if not agent then
          local name = agent_process(fg)
          agent = name and { state = "unknown", app = name }
        end

        if agent then
          local title = method "title"
          local tab = tabs[b.window_id] or { index = 0 }
          agent.app = agent.app or agent_process(fg) or "agent"
          agent.title = one_line(title and title.title or "")
          agent.cwd_name = fg and fg.cwd and fg.cwd:match "([^/]+)/*$"
          agent.session = s.label
          agent.session_id = s.session_id
          agent.session_order = order
          agent.tab = tab.index
          agent.tab_label = tab.label
          agent.window_id = b.window_id
          agent.block_id = b.block_id
          agents[#agents + 1] = agent
        end
      end
    end
  end

  table.sort(agents, function(a, b)
    local ra, rb = AGENT_RANK[a.state], AGENT_RANK[b.state]
    if ra ~= rb then
      return ra < rb
    end
    if a.session_order ~= b.session_order then
      return a.session_order < b.session_order
    end
    return a.tab < b.tab
  end)
  return agents
end

-- Seconds since the epoch for an RFC 3339 timestamp, or nil.
local function parse_time(stamp)
  local y, mo, d, h, mi, s, rest = (stamp or ""):match "^(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)%.?%d*(.*)$"
  if not y then
    return nil
  end
  local offset = 0
  local sign, oh, om = rest:match "^([+-])(%d+):(%d+)$"
  if sign then
    offset = (tonumber(oh) * 3600 + tonumber(om) * 60) * (sign == "-" and -1 or 1)
  end
  -- os.time reads the table as local time. Shift it to UTC, then by the
  -- stamp's own offset.
  local t = os.time { year = y, month = mo, day = d, hour = h, min = mi, sec = s, isdst = false }
  local utc = os.date("!*t", t)
  utc.isdst = false
  return t + (t - os.time(utc)) - offset
end

local function ago(stamp)
  local t = parse_time(stamp)
  if not t then
    return ""
  end
  local s = math.max(os.time() - t, 0)
  if s < 60 then
    return "now"
  elseif s < 3600 then
    return math.floor(s / 60) .. "m"
  elseif s < 86400 then
    return math.floor(s / 3600) .. "h"
  end
  return math.floor(s / 86400) .. "d"
end

-- What tells an agent apart from the others in its session: the message it
-- reported (pi's session name, or what a blocked agent waits for), else the
-- tab's name. Agents without a status fall back to their terminal title.
local function agent_label(a)
  local label = one_line(a.msg)
  if label == "" and a.tab_label then
    label = a.tab_label
  end
  if label == "" and a.state == "unknown" then
    -- Skip titles that only say the app and where it runs, like
    -- "OpenCode - dots".
    local title = a.title:gsub("^[^%w]+", "")
    local head, tail = title:match "^(.-)%s+[^%w%s]+%s+(.+)$"
    if head and head:lower():gsub("[^%w]", "") == a.app:lower():gsub("[^%w]", "") then
      title = tail
    end
    if title ~= a.session and title ~= a.cwd_name and title:lower() ~= a.app:lower() then
      label = title
    end
  end
  return label
end

-- The picker title with the number of agents in each state, most urgent
-- first, such as "Pick an agent · 1 blocked · 2 working".
local function agents_title(agents)
  local counts, states = {}, {}
  for _, a in ipairs(agents) do
    if not counts[a.state] then
      states[#states + 1] = a.state
    end
    counts[a.state] = (counts[a.state] or 0) + 1
  end
  table.sort(states, function(a, b)
    return AGENT_RANK[a] < AGENT_RANK[b]
  end)
  local parts = { cfg.agents.title }
  for _, state in ipairs(states) do
    parts[#parts + 1] = counts[state] .. " " .. state
  end
  return table.concat(parts, " · ")
end

-- One picker item per agent, keyed by its block ID.
local function agent_items(agents)
  -- Name tabs only where two agents of a session would look the same.
  local groups = {}
  for _, a in ipairs(agents) do
    a.label = agent_label(a)
    local key = a.session_id .. "\0" .. a.label
    groups[key] = (groups[key] or 0) + 1
  end

  local items = {}
  for _, a in ipairs(agents) do
    local subtitle = { a.app }
    if a.label ~= "" then
      subtitle[#subtitle + 1] = a.label
    end
    if groups[a.session_id .. "\0" .. a.label] > 1 then
      subtitle[#subtitle + 1] = "tab " .. a.tab
    end

    local time = a.state ~= "unknown" and ago(a.updated_at) or ""
    items[#items + 1] = {
      id = a.block_id,
      title = a.session,
      subtitle = table.concat(subtitle, " · "),
      icon = icon(cfg.agents.icons[a.state] or cfg.agents.icons.idle),
      detail = time ~= "" and (a.state .. " · " .. time) or a.state,
    }
  end
  return items
end

local function focus_agent(ctx, agent)
  local call = server_caller()
  local _, err = call("session.focus_block", { session_id = agent.session_id, block_id = agent.block_id })
  if err ~= nil then
    error("dactyl: " .. tostring(err), 0)
  end
  local result = select_session(agent.session_id, ctx.session_id, agent.window_id)
  result.block_id = agent.block_id
  return result
end

local function pick_agent(ctx, args)
  local agents = list_agents(ctx.block_id)
  local block_id = args and args.block_id
  if not block_id then
    if #agents == 0 then
      rex.log("info", "dactyl: no agents running")
      return nil
    end
    block_id = ask {
      title = agents_title(agents),
      placeholder = cfg.agents.placeholder,
      confirm = cfg.agents.confirm,
      items = agent_items(agents),
    }
    if block_id == nil then
      return nil
    end
  end

  for _, a in ipairs(agents) do
    if a.block_id == block_id then
      return focus_agent(ctx, a)
    end
  end
  error("dactyl: no agent in " .. tostring(block_id), 0)
end

-- Setup ---------------------------------------------------------------------

---@param opts? dactyl.Options
function M.setup(opts)
  cfg = merge(defaults, opts)
  cfg.keys = merge(defaults.keys, opts and opts.keys)
  local agents = opts and opts.agents or {}
  cfg.agents = merge(defaults.agents, agents)
  cfg.agents.icons = merge(defaults.agents.icons, agents.icons)

  rex.action {
    name = "dactyl",
    title = "Dactyl: Pick Session…",
    description = "Pick an open session, workspace or zoxide directory.",
    category = "Sessions",
    keywords = "sesh yeet zoxide session switch",
    args = { target = "string?" },
    run = pick,
  }

  rex.action {
    name = "dactyl_last",
    title = "Dactyl: Last Session",
    description = "Switch back to the session you came from.",
    category = "Sessions",
    run = last,
  }

  rex.action {
    name = "dactyl_agents",
    title = "Dactyl: Pick Agent…",
    description = "Pick a running coding agent in any session by its status.",
    category = "Sessions",
    keywords = "agent pi claude codex status blocked done",
    args = { block_id = "string?" },
    run = pick_agent,
  }

  if cfg.keys.pick then
    rex.bind(cfg.keys.pick, "dactyl")
  end
  if cfg.keys.last then
    rex.bind(cfg.keys.last, "dactyl_last")
  end
  if cfg.keys.agents then
    rex.bind(cfg.keys.agents, "dactyl_agents")
  end
end

return M
