#!/usr/bin/env bash
# ~/.config/niri/scripts/notif-menu.sh

pkill -x fuzzel && exit 0

history=$(makoctl history -j 2>/dev/null)

entries=$(echo "$history" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if not data:
    print('  No notifications')
else:
    for n in data:
        app = n.get('app_name') or 'unknown'
        summary = n.get('summary') or ''
        body = n.get('body') or ''
        line = f'{app}  {summary}'
        if body:
            line += f'  {body}'
        if len(line) > 80:
            line = line[:77] + '...'
        print(line)
" 2>/dev/null)

[ -z "$entries" ] && entries="  No notifications"

echo "$entries" | fuzzel --dmenu \
  --placeholder "notifications" \
  --lines 10 \
  --width 55 \
  --anchor top-right \
  --no-run-if-empty
