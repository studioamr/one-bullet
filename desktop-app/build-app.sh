#!/bin/bash
# Ensambla SPOTTER AI.app (bundle nativo) desde el binario compilado + el contenido de la plataforma.
set -e
cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"
APP="SPOTTER AI.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# 1) binario
cp "SPOTTER AI" "$APP/Contents/MacOS/SPOTTER AI"
chmod +x "$APP/Contents/MacOS/SPOTTER AI"

# 2) contenido de la plataforma (autónomo, dentro del .app)
cp "$ROOT/index.html" "$APP/Contents/Resources/index.html"
mkdir -p "$APP/Contents/Resources/assets"
cp "$ROOT/assets/icon_192.png" "$APP/Contents/Resources/assets/icon_192.png"
cp "$ROOT/assets/icon_512.png" "$APP/Contents/Resources/assets/icon_512.png" 2>/dev/null || true
# ícono azul del bundle
cp "$ROOT/assets/spotter.icns" "$APP/Contents/Resources/spotter.icns"

# 3) Info.plist
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>SPOTTER AI</string>
  <key>CFBundleDisplayName</key><string>SPOTTER AI</string>
  <key>CFBundleIdentifier</key><string>com.spotterai.app</string>
  <key>CFBundleVersion</key><string>1.0</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleExecutable</key><string>SPOTTER AI</string>
  <key>CFBundleIconFile</key><string>spotter</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSHumanReadableCopyright</key><string>© 2026 SPOTTER AI</string>
</dict>
</plist>
PLIST

# 4) PkgInfo
printf 'APPL????' > "$APP/Contents/PkgInfo"

# 5) firma ad-hoc (evita "está dañada"; el usuario igual da clic derecho → Abrir la 1a vez)
codesign --force --deep --sign - "$APP" 2>/dev/null && echo "firmado ad-hoc" || echo "(sin codesign)"

echo "listo: $APP"
