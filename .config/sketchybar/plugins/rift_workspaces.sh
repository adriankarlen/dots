#!/usr/bin/env bash
# Map macOS bundle_id or app name to Nerd Font icon
app_icon() {
  case "$1" in
    # Browsers
    "com.apple.Safari" | Safari)                          echo " " ;;
    Firefox | "org.mozilla.firefox")                      echo " " ;;
    "com.google.Chrome" | "Google Chrome")                echo " " ;;
    "com.brave.Browser" | Brave*)                         echo " " ;;
    "com.microsoft.edgemac" | "Microsoft Edge")           echo " " ;;
    "org.mozilla.firefoxdeveloperedition" | \
    "Firefox Developer Edition")                          echo " " ;;

    # Terminals
    "com.apple.Terminal" | Terminal)                      echo " " ;;
    "com.googlecode.iterm2" | iTerm2)                     echo " " ;;
    Ghostty | "com.mitchellh.ghostty")                    echo " " ;;
    "net.kovidgoyal.kitty" | kitty)                       echo " " ;;
    "io.alacritty" | Alacritty)                           echo " " ;;
    "org.wezfurlong.wezterm" | WezTerm)                   echo " " ;;

    # Editors / IDE
    Code | "com.microsoft.VSCode" | \
    "com.visualstudio.code")                              echo " " ;;
    "com.microsoft.VSCodeInsiders" | \
    "Visual Studio Code - Insiders")                      echo " " ;;
    "com.jetbrains.intellij" | IntelliJ*)                 echo " " ;;
    "com.jetbrains.pycharm" | PyCharm*)                   echo " " ;;
    "com.jetbrains.webstorm" | WebStorm*)                 echo " " ;;
    "com.sublimetext.4" | "Sublime Text")                 echo " " ;;
    "com.apple.dt.Xcode" | Xcode)                         echo " " ;;

    # Chat / meetings
    Discord | "com.hnc.Discord")                          echo " " ;;
    "com.tinyspeck.slackmacgap" | Slack)                  echo " " ;;
    "us.zoom.xos" | zoom.us | Zoom)                       echo " " ;;
    "com.microsoft.teams" | \
    "com.microsoft.teams2" | Microsoft\ Teams)            echo "󰊻 " ;;
    "com.microsoft.Outlook" | Microsoft\ Outlook)         echo "󰇰 " ;;
    "com.apple.FaceTime" | FaceTime)                      echo " " ;;
    "com.apple.iChat" | "com.apple.MobileSMS" | Messages) echo "󰭹 " ;;
    "com.apple.mail" | Mail)                              echo " " ;;

    # Music / media
    Spotify | "com.spotify.client")                       echo " " ;;
    "com.apple.Music" | Music)                            echo " " ;;
    "com.apple.TV" | TV)                                  echo " " ;;
    "com.apple.QuickTimePlayerX" | QuickTime*)            echo " " ;;
    "org.videolan.vlc" | VLC)                             echo " " ;;

    # Apple / system
    "com.apple.finder" | Finder)                          echo " " ;;
    "com.apple.systempreferences" | \
    "com.apple.SystemSettings" | \
    "System Preferences" | "System Settings")             echo " " ;;
    "com.apple.ActivityMonitor" | Activity\ Monitor)      echo " " ;;
    "com.apple.Console" | Console)                        echo " " ;;
    "com.apple.DiskUtility" | Disk\ Utility)              echo " " ;;
    "com.apple.TimeMachine" | Time\ Machine)              echo " " ;;
    "com.apple.AppStore" | App\ Store)                    echo " " ;;
    "com.apple.Preview" | Preview)                        echo " " ;;
    "com.apple.Photos" | Photos)                          echo " " ;;
    "com.apple.Calculator" | Calculator)                  echo " " ;;
    "com.apple.Calendar" | Calendar)                      echo " " ;;
    "com.apple.Notes" | Notes)                            echo " " ;;
    "com.apple.Reminders" | Reminders)                    echo " " ;;
    "com.apple.Maps" | Maps)                              echo " " ;;
    "com.apple.Dictionary" | Dictionary)                  echo " " ;;
    "com.apple.TextEdit" | TextEdit)                      echo " " ;;
    "com.apple.Stickies" | Stickies)                      echo " " ;;
    "com.apple.FontBook" | Font\ Book)                    echo " " ;;
    "com.apple.Screenshot" | Screenshot)                  echo " " ;;
    "com.apple.ImageCapture" | Image\ Capture)            echo " " ;;
    "com.apple.Automator" | Automator)                    echo " " ;;
    "com.apple.Shortcuts" | Shortcuts)                    echo " " ;;
    "com.apple.Home" | Home)                              echo " " ;;
    "com.apple.Books" | Books)                            echo " " ;;
    "com.apple.News" | News)                              echo " " ;;
    "com.apple.Poddcasts" | Podcasts | \
    "com.apple.podcasts")                                 echo " " ;;

    # Cloud / notes / productivity
    "com.notion.id" | Notion)                             echo " " ;;
    "com.electron.logseq" | Logseq)                       echo " " ;;
    "md.obsidian" | Obsidian)                             echo " " ;;
    "com.todoist.mac.Todoist" | Todoist)                  echo " " ;;
    "com.apple.iWork.Pages" | Pages)                      echo " " ;;
    "com.apple.iWork.Numbers" | Numbers)                  echo " " ;;
    "com.apple.iWork.Keynote" | Keynote)                  echo " " ;;
    "com.microsoft.Word" | Microsoft\ Word)               echo " " ;;
    "com.microsoft.Excel" | Microsoft\ Excel)             echo " " ;;
    "com.microsoft.Powerpoint" | Microsoft\ PowerPoint)   echo " " ;;

    # Dev tools
    "com.apple.SafariTechnologyPreview" | \
    "Safari Technology Preview")                          echo " " ;;
    "com.postmanlabs.mac" | Postman)                      echo " " ;;
    "com.docker.docker" | Docker)                         echo " " ;;
    "com.github.GitHubClient" | GitHub\ Desktop)          echo " " ;;
    "com.tinyspeck.slackmacgap" | Slack)                  echo " " ;;
    "com.jgraph.drawio.desktop" | draw.io)                echo " " ;;

    *)
      echo " "
      ;;
  esac
}

RIFT_DATA="$(rift-cli query workspaces 2>/dev/null)" || exit 0
workspace_count=$(printf '%s\n' "$RIFT_DATA" | jq 'length')

for (( i=0; i<workspace_count; i++ )); do
  sid=$((i + 1))

  # Check if this workspace is active
  is_active=$(printf '%s\n' "$RIFT_DATA" | jq -r ".[$i].is_active")

  # Get unique bundle_ids for this workspace
  bundle_ids=$(printf '%s\n' "$RIFT_DATA" \
    | jq -r ".[$i].windows[].bundle_id" 2>/dev/null | sort -u)

  icons=""
  if [ -n "$bundle_ids" ]; then
    while IFS= read -r bid; do
      [ -z "$bid" ] && continue
      icons+=$(app_icon "$bid")
    done <<< "$bundle_ids"
  fi

  # Fallback: no windows, no icons
  [ -z "$icons" ] && icons=""

  # Base args
  args=(label="$icons" label.padding_right=0)

  # Add highlight based on active state
  if [ "$is_active" = "true" ]; then
    args+=(icon.highlight=on)
  else
    args+=(icon.highlight=off)
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
for (( i=workspace_count; i<max_spaces; i++ )); do
  sid=$((i + 1))
  sketchybar --set "rift_space.$sid" icon.highlight=off label.drawing=off 2>/dev/null
done
