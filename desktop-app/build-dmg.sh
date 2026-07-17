#!/bin/bash
# Empaqueta SPOTTER AI.app en un DMG con arrastre visual (app → Aplicaciones).
set -e
cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"
APP="SPOTTER AI.app"
VOL="SPOTTER AI"
DMG_TMP="spotter-tmp.dmg"
DMG_FINAL="$ROOT/download/SPOTTER-AI.dmg"

osascript -e 'quit app "SPOTTER AI"' 2>/dev/null || true
sleep 1

STAGE="dmg-stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/.background"
cp -R "$APP" "$STAGE/"
cp dmg-bg.png "$STAGE/.background/bg.png"
ln -s /Applications "$STAGE/Applications"
xattr -cr "$STAGE/$APP" 2>/dev/null || true

rm -f "$DMG_TMP"
hdiutil create -srcfolder "$STAGE" -volname "$VOL" -fs HFS+ -format UDRW -ov "$DMG_TMP" >/dev/null

MOUNT_DIR="/Volumes/$VOL"
hdiutil detach "$MOUNT_DIR" 2>/dev/null || true
DEV=$(hdiutil attach -readwrite -noverify -noautoopen "$DMG_TMP" | egrep '^/dev/' | head -1 | awk '{print $1}')
sleep 2

osascript <<EOF || echo "(layout applescript falló — DMG funcional, sin fondo)"
tell application "Finder"
  tell disk "$VOL"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set the bounds of container window to {200, 120, 860, 540}
    set vopts to the icon view options of container window
    set arrangement of vopts to not arranged
    set icon size of vopts to 112
    set text size of vopts to 12
    set background picture of vopts to file ".background:bg.png"
    set position of item "$APP" of container window to {175, 200}
    set position of item "Applications" of container window to {485, 200}
    update without registering applications
    delay 1
    close
  end tell
end tell
EOF

sync
hdiutil detach "$DEV" 2>/dev/null || hdiutil detach "$MOUNT_DIR" 2>/dev/null || true
sleep 1

mkdir -p "$ROOT/download"
rm -f "$DMG_FINAL"
hdiutil convert "$DMG_TMP" -format UDZO -imagekey zlib-level=9 -o "$DMG_FINAL" >/dev/null
rm -f "$DMG_TMP"
rm -rf "$STAGE"
echo "DMG final:"; ls -lh "$DMG_FINAL"
