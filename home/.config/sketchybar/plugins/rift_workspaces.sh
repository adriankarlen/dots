#!/usr/bin/env bash
# Workspace app icons: sketchybar-app-font ligatures from helpers/icon_map.sh
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/helpers/icon_map.sh"

app_icon() {
  __icon_map "$1"
  echo "$icon_result"
}

RIFT_DATA="$(rift-cli query workspaces 2>/dev/null)" || exit 0
workspace_count=$(printf '%s\n' "$RIFT_DATA" | jq 'length')

for ((i = 0; i < workspace_count; i++)); do
  sid=$((i + 1))

  # Check if this workspace is active
  is_active=$(printf '%s\n' "$RIFT_DATA" | jq -r ".[$i].is_active")

  # Unique app names for this workspace
  app_names=$(printf '%s\n' "$RIFT_DATA" |
    jq -r ".[$i].windows[].app_name" 2>/dev/null | sort -u)

  icons=""
  if [ -n "$app_names" ]; then
    while IFS= read -r app; do
      [ -z "$app" ] && continue
      icons+="$(app_icon "$app") "
    done <<<"$app_names"
    icons="${icons% }"
  fi

  # Fallback: no windows, no icons
  [ -z "$icons" ] && icons=""

  # Base args
  args=(label="$icons" label.padding_right=0)

  # Add highlight based on active state
  if [ "$is_active" = "true" ]; then
    args+=(icon.highlight=on background.drawing=on)
  else
    args+=(icon.highlight=off background.drawing=off)
  fi

  if [ -n "$icons" ]; then
    args+=(label="$icons" label.drawing=on label.padding_left=0 label.padding_right=10)
  else
    args+=(label.drawing=off)
  fi

  sketchybar --set "rift_space.$sid" "${args[@]}"
done

# Reset stale workspaces beyond current count
max_spaces=10
for ((i = workspace_count; i < max_spaces; i++)); do
  sid=$((i + 1))
  sketchybar --set "rift_space.$sid" icon.highlight=off background.drawing=off label.drawing=off 2>/dev/null
done
