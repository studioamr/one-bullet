#!/bin/bash
# SPOTTER AI — instala (UNA sola vez) el lanzador nativo.
# Después, el botón "Start Session" de la app abre Claude Code de un clic (esquema spotter://).
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
CMD="$HERE/start-watch.command"
APP="$HOME/Applications/Spotter Launcher.app"

if [ ! -f "$CMD" ]; then
  echo "No encontré start-watch.command junto a este archivo. Ten los dos en la misma carpeta."
  read -n 1 -s -r -p "   Enter para cerrar…"; exit 1
fi
chmod +x "$CMD"
mkdir -p "$HOME/Applications"

# 1) AppleScript que, al recibir spotter://, abre Terminal y corre tu lanzador
TMP="$(mktemp /tmp/spotter_XXXX)".applescript
cat > "$TMP" <<APPLESCRIPT
on open location this_URL
	my launch()
end open location
on run
	my launch()
end run
on launch()
	tell application "Terminal"
		activate
		do script "'$CMD'"
	end tell
end launch
APPLESCRIPT

# 2) compilar a .app
rm -rf "$APP"
osacompile -o "$APP" "$TMP"
rm -f "$TMP"

# 3) declarar el esquema spotter://
PLIST="$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLName string com.spotterai.launch" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string spotter" "$PLIST"

# 4) registrar en el sistema
LSREG="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
[ -x "$LSREG" ] && "$LSREG" -f "$APP" || true
open "$APP" >/dev/null 2>&1 || true

clear
echo ""
echo "   ✓ Listo. Lanzador nativo de SPOTTER AI instalado."
echo "   Ahora, en la app, dale 'Start Session' y el Spotter arranca solo."
echo ""
read -n 1 -s -r -p "   Enter para cerrar…"
