#!/bin/sh
test -f ngui.dmg && rm ngui.dmg
create-dmg \
  --volname "ngui" \
  --background "dmg-bg.png" \
  --window-pos 200 120 \
  --window-size 451 524 \
  --icon-size 100 \
  --icon "ngui.app" 129 356 \
  --hide-extension "ngui.app" \
  --app-drop-link 323 356 \
  "ngui.dmg" \
  "./app"

