-- dactyl: a sesh/yeet-style session picker for Rex.
--
-- Lists open Rex sessions, configured workspaces and zoxide directories in a
-- floating `gum filter` pane. Picking an entry switches to that session, or
-- creates it in the right directory first.
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
-- Switching sessions from the picker needs Remote Control turned on in
-- Rex.app (Settings > Rex Server).

local M = {}

local HOME = os.getenv "HOME" or ""
local TERMINAL = "com.superlogical.terminal"
local SHELL_FLAVOR = TERMINAL .. ".shell"
local STATE_DIR = (os.getenv "XDG_STATE_HOME" or (HOME .. "/.local/state")) .. "/dactyl"
local LAST_FILE = STATE_DIR .. "/last"

-- Nerd Font icons, same as yeet: session, workspace, directory.
local ICONS = {
  session = "\27[36m\27[39m",
  workspace = "\27[90m\27[39m",
  dir = "\27[36m\27[39m",
}

---@class dactyl.Keys
---@field pick? string|false Opens the picker. `false` leaves it unbound.
---@field last? string|false Switches to the last session. `false` leaves it unbound.
---@field agents? string|false Opens the agent picker. `false` leaves it unbound.

---@class dactyl.Agents
---@field processes string[] Process names counted as agents when they report no status.
---@field placeholder string
---@field glyphs table<string, string> Short mark per app, such as `pi = "π"`. Other apps show their name.
---@field colors table<string, string> `#rrggbb` per state (`blocked`, `error`, `done`, `working`, `idle`) and for `glyph`, `subtle` and `muted` text.
---@field label_width integer Longest label shown before it is cut short.

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
---@field agents? dactyl.Agents
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
    placeholder = "Pick an agent",
    glyphs = { pi = "󰏿", claude = "", ["claude-code"] = "", opencode = "󰝣" }, -- opencode: md-square_outline
    -- Rosé Pine.
    colors = {
      blocked = "#eb6f92",
      error = "#eb6f92",
      done = "#9ccfd8",
      working = "#f6c177",
      idle = "#6e6a86",
      glyph = "#c4a7e7",
      subtle = "#908caa",
      muted = "#6e6a86",
    },
    label_width = 36,
  },
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

-- Agents --------------------------------------------------------------------

-- Ordered by how much they need you. A state Rex adds later counts as idle.
-- `color` names an entry in `agents.colors`. Icons are Nerd Font glyphs.
local AGENT_STATES = {
  blocked = { rank = 1, icon = "", color = "blocked" }, -- fa-hand_paper_o
  error = { rank = 2, icon = "", color = "error" }, -- fa-times_circle
  done = { rank = 3, icon = "", color = "done" }, -- fa-check_circle
  working = { rank = 4, icon = "", color = "working" }, -- fa-spinner
  idle = { rank = 5, icon = "", color = "idle" }, -- fa-pause_circle
  unknown = { rank = 6, icon = "󰘥", color = "idle" }, -- md-help_circle_outline
}

-- States that outlive the program that reported them. Rex drops `working`
-- and `blocked` itself when the program exits.
local STICKY_STATES = { done = true, error = true, idle = true }

-- Colour text with a `#rrggbb` hex colour, resetting only the foreground so
-- gum's cursor row styling still shows through.
local function paint(hex, s)
  local r, g, b = (hex or ""):match "^#(%x%x)(%x%x)(%x%x)$"
  if not r or s == "" then
    return s
  end
  return string.format("\27[38;2;%d;%d;%dm%s\27[39m", tonumber(r, 16), tonumber(g, 16), tonumber(b, 16), s)
end

local function color(name)
  return cfg.agents.colors[name]
end

-- Display width of a UTF-8 string, close enough for names and labels.
local function width(s)
  return #s:gsub("[\128-\191]", "")
end

local function pad(s, w)
  return s .. string.rep(" ", w - width(s))
end

local function one_line(s)
  return trim((s or ""):gsub("%c", " "))
end

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
      local state = AGENT_STATES[r.state] and r.state or "idle"
      if not best or AGENT_STATES[state].rank < AGENT_STATES[best.state].rank then
        best = {
          state = state,
          app = r.effective_app or r.app,
          kind = r.kind,
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
    local ra, rb = AGENT_STATES[a.state].rank, AGENT_STATES[b.state].rank
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

local function shorten(s, w)
  if width(s) <= w then
    return s
  end
  local out, n = {}, 0
  for ch in s:gmatch "[%z\1-\127\194-\244][\128-\191]*" do
    if n >= w - 1 then
      break
    end
    out[#out + 1] = ch
    n = n + 1
  end
  return table.concat(out) .. "…"
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

-- Coloured counts per state for the picker header, most urgent first.
local function agent_header(agents)
  local counts = {}
  for _, a in ipairs(agents) do
    counts[a.state] = (counts[a.state] or 0) + 1
  end
  local states = {}
  for name, st in pairs(AGENT_STATES) do
    if counts[name] then
      states[#states + 1] = { name = name, st = st }
    end
  end
  table.sort(states, function(a, b)
    return a.st.rank < b.st.rank
  end)
  local parts = {}
  for _, s in ipairs(states) do
    local mark = cfg.icons and s.st.icon or s.name
    parts[#parts + 1] = paint(color(s.st.color), mark) .. " " .. paint(color "subtle", tostring(counts[s.name]))
  end
  return table.concat(parts, "   ")
end

-- One aligned picker line per agent, plus the arguments for
-- dactyl_agent_focus on the matching line of `ids`.
local function agent_lines(agents)
  -- Number tabs only where two agents of a session would look the same.
  local groups = {}
  for _, a in ipairs(agents) do
    a.label = shorten(agent_label(a), cfg.agents.label_width)
    local key = a.session_id .. "\0" .. a.label
    groups[key] = (groups[key] or 0) + 1
  end

  local w_session, w_app, w_label, w_time = 0, 0, 0, 0
  for _, a in ipairs(agents) do
    a.glyph = cfg.agents.glyphs[a.app] or a.app
    a.tab_mark = groups[a.session_id .. "\0" .. a.label] > 1 and ("tab " .. a.tab) or ""
    a.time = a.state ~= "unknown" and ago(a.updated_at) or ""
    local label_w = width(a.label) + (a.tab_mark ~= "" and a.label ~= "" and 2 or 0) + width(a.tab_mark)
    w_session = math.max(w_session, width(a.session))
    w_app = math.max(w_app, width(a.glyph))
    w_label = math.max(w_label, label_w)
    w_time = math.max(w_time, width(a.time))
  end

  local lines, ids, seen = {}, {}, {}
  for _, a in ipairs(agents) do
    local st = AGENT_STATES[a.state]
    local label = paint(color "subtle", a.label)
    if a.tab_mark ~= "" then
      label = label .. (a.label ~= "" and "  " or "") .. paint(color "muted", a.tab_mark)
    end
    local label_w = width(a.label) + (a.tab_mark ~= "" and a.label ~= "" and 2 or 0) + width(a.tab_mark)

    local line = table.concat {
      paint(color(st.color), cfg.icons and st.icon or pad(a.state, 7)),
      "  ",
      pad(a.session, w_session),
      "  ",
      paint(color "glyph", a.glyph),
      string.rep(" ", w_app - width(a.glyph)),
      "  ",
      label,
      string.rep(" ", w_label - label_w),
      "  ",
      string.rep(" ", w_time - width(a.time)),
      paint(color "muted", a.time),
    }
    line = line:gsub("%s+$", "")
    -- Keep lines unique so the picked one maps back to a single pane.
    if seen[line] then
      line = line .. paint(color "muted", "  #" .. a.block_id:sub(-4))
    end
    seen[line] = true

    lines[#lines + 1] = line
    ids[#ids + 1] = table.concat({
      "session_id=" .. a.session_id,
      "window_id=" .. a.window_id,
      "block_id=" .. a.block_id,
    }, " ")
  end
  return lines, ids
end

-- Picker --------------------------------------------------------------------

local function write_lines(lines)
  local path = os.tmpname()
  local f = assert(io.open(path, "w"))
  f:write(table.concat(lines, "\n"), "\n")
  f:close()
  return path
end

-- The picked line is passed to the action as `target=<line>`. With `ids`, the
-- matching line of `ids` is passed instead, split into `key=value` words.
local PICKER_SCRIPT = [[
list="$1" ids="$2" client="$3" from="$4" placeholder="$5" setup="$6" prompt="$7" action="$8" header="$9"
# Clear the arguments so a sourced theme script doesn't inherit them.
set --
printf '\033]2;dactyl\007'
[ -n "$setup" ] && eval "$setup" >/dev/null 2>&1
choice=$(gum filter --limit 1 --no-sort --fuzzy --no-strip-ansi \
  --placeholder "$placeholder" --prompt "$prompt" --header "$header" < "$list")
status=$?
args=""
if [ $status -eq 0 ] && [ -n "$choice" ] && [ -n "$ids" ]; then
  # Find the picked line, ignoring colors and surrounding blanks.
  n=$(C="$choice" awk '
    function plain(x) {
      gsub(sprintf("%c", 27) "\\[[0-9;]*m", "", x)
      gsub(/^[ \t]+|[ \t]+$/, "", x)
      return x
    }
    BEGIN { c = plain(ENVIRON["C"]) }
    plain($0) == c { print NR; exit }
  ' "$list")
  [ -n "$n" ] && args=$(sed -n "${n}p" "$ids")
fi
rm -f "$list"
[ -n "$ids" ] && rm -f "$ids"
[ $status -eq 0 ] && [ -n "$choice" ] || exit 0
if [ -z "$ids" ]; then
  set -- target="$choice"
elif [ -n "$args" ]; then
  set -- $args
else
  exit 0
fi
if [ -n "$client" ]; then
  rex -C "$client" do "$action" "$@" from="$from" >/dev/null
else
  rex do "$action" "$@" from="$from" >/dev/null
fi || { echo "dactyl: could not connect to $choice"; read -r -n 1; }
]]

---@param ctx table
---@param opts { lines: string[], ids?: string[], placeholder: string, action: string, header?: string }
local function open_picker(ctx, opts)
  local list = write_lines(opts.lines)
  local ids = opts.ids and write_lines(opts.ids) or ""

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
            PICKER_SCRIPT,
            cfg.label,
            list,
            ids,
            ctx.client_id or "",
            ctx.session_id or "",
            opts.placeholder,
            cfg.gum_setup or "",
            cfg.prompt,
            opts.action,
            opts.header or "",
          },
        },
      },
    },
  }
  if err ~= nil then
    os.remove(list)
    if ids ~= "" then
      os.remove(ids)
    end
    error("dactyl: " .. tostring(err), 0)
  end
end

-- Actions -------------------------------------------------------------------

local function pick(ctx)
  local items = build_items(ctx.session_id)
  if #items == 0 then
    return
  end
  open_picker(ctx, { lines = items, placeholder = cfg.placeholder, action = "dactyl_connect" })
end

local function pick_agent(ctx)
  local agents = list_agents(ctx.block_id)
  if #agents == 0 then
    rex.log("info", "dactyl: no agents running")
    return
  end
  local lines, ids = agent_lines(agents)
  open_picker(ctx, {
    lines = lines,
    ids = ids,
    placeholder = cfg.agents.placeholder,
    action = "dactyl_agent_focus",
    header = agent_header(agents),
  })
end

local function select_session(id, from, window_id)
  if from and from ~= id then
    write_last(from)
  end
  rex.client.queue("session.select", { session_id = id, window_id = window_id })
  return { session_id = id, window_id = window_id }
end

local function focus_agent(ctx, args)
  local call = server_caller()
  local _, err = call("session.focus_block", { session_id = args.session_id, block_id = args.block_id })
  if err ~= nil then
    error("dactyl: " .. tostring(err), 0)
  end
  local result = select_session(args.session_id, args.from or ctx.session_id, args.window_id)
  result.block_id = args.block_id
  return result
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
  local agents = opts and opts.agents or {}
  cfg.agents = merge(defaults.agents, agents)
  cfg.agents.glyphs = merge(defaults.agents.glyphs, agents.glyphs)
  cfg.agents.colors = merge(defaults.agents.colors, agents.colors)

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

  rex.action {
    name = "dactyl_agents",
    title = "Dactyl: Pick Agent…",
    description = "Pick a running coding agent in any session by its status.",
    category = "Sessions",
    keywords = "agent pi claude codex status blocked done",
    run = pick_agent,
  }

  rex.action {
    name = "dactyl_agent_focus",
    title = "Dactyl: Focus Agent",
    description = "Switch to an agent's session and focus its pane.",
    category = "Sessions",
    args = {
      session_id = "string",
      block_id = "string",
      window_id = "string?",
      from = "string?",
    },
    run = focus_agent,
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
