# SPOTTER AI — app nativa de escritorio (Mac)

App de Mac de verdad (WKWebView nativo, su propia ventana, sin navegador) que empaqueta la
plataforma (`../index.html`) adentro. Se distribuye en un DMG con arrastre a Aplicaciones.

## Reconstruir (desde `candado/`)

```bash
cd desktop-app
# 1) compilar el binario universal (Intel + Apple Silicon)
swiftc -O -target arm64-apple-macos11  main.swift -o spotter_arm -framework Cocoa -framework WebKit
swiftc -O -target x86_64-apple-macos11 main.swift -o spotter_x86 -framework Cocoa -framework WebKit
lipo -create spotter_arm spotter_x86 -output "SPOTTER AI"
# 2) ensamblar el .app (mete index.html + ícono azul spotter.icns)
./build-app.sh
# 3) empaquetar el DMG con el arrastre visual → ../download/SPOTTER-AI.dmg
python3 make_dmg_bg.py   # regenera el fondo del instalador
./build-dmg.sh
```

Cada vez que cambie `../index.html` hay que correr `build-app.sh` + `build-dmg.sh` de nuevo
para que el DMG lleve la versión nueva.

## Notas
- **No está firmado con cuenta de Apple Developer** → la 1ª vez el usuario debe hacer
  clic derecho sobre la app → Abrir → Abrir (Gatekeeper). Sin eso, macOS lo bloquea.
  Para firmarlo/notarizarlo de verdad hace falta cuenta de desarrollador ($99/año).
- El ícono azul vive en `../assets/spotter.icns` (generado por `../assets/make_icon.py`).
- Enlaces externos (Discord/WhatsApp/TradingView) se abren en el navegador del sistema;
  la navegación interna se queda dentro de la app.
