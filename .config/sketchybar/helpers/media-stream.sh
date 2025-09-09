media-control stream | \
    while IFS= read -r line; do
        if [ "$(jq -r '.diff == false' <<< "$line")" = "true" ]; then
            playback=$(jq -r '.payload.playback' <<< "$line")
            title=$(jq -r '.payload.title' <<< "$line")
            artist=$(jq -r '.payload.artist' <<< "$line")
           sketchybar --trigger media_stream_changed playback="$playback" title="$title" artist="$artist"
        fi
    done
