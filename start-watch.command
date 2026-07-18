#!/bin/bash
# SPOTTER AI — arranca al Spotter: Claude vigila tu TradingView en vivo, en automático.
DIR="$HOME/Library/Application Support/SpotterAI"
cd "$HOME/claude" 2>/dev/null || cd "$HOME"
CLAUDE="$HOME/.local/bin/claude"
[ -x "$CLAUDE" ] || CLAUDE="$(command -v claude)"

read -r -d '' PROMPT <<EOP
Eres mi SPOTTER de trading en vivo. Primero, UNA sola vez y sin repetir:
1) Lee mi perfil: $DIR/profile.json (mi nombre, cuenta, reglas, meta/why, fase, historial y stats).
2) Lee tu manual: $DIR/SPOTTER-PLAYBOOK.md (tus 25 comportamientos) y SÍGUELO al pie de la letra.
ARRANCA YA: salúdame por mi nombre, captura mi pantalla (screencapture -x /tmp/spotter.png y reduce con sips -Z 1000 /tmp/spotter.png ANTES de leerla), y háblame por voz en español latino (say -v Juan, o si no existe say -v Paulina) de la situación actual de mi TradingView.
Luego vigila en modo EFICIENTE del playbook: cadencia ~30-45s, contexto ya está en memoria (no lo releas), imagen reducida, y habla SOLO cuando importa. NUNCA señales de compra/venta ni mover stops. Al cerrar mi operación dame resumen hablado y guarda un debrief en $DIR/. Para cuando diga "terminé".
EOP

clear
echo ""
echo "   ◉  SPOTTER AI — el Spotter se está conectando…"
echo ""

if [ -n "$CLAUDE" ] && [ -x "$CLAUDE" ]; then
  echo "   Arrancando en automático — el Spotter va a empezar a hablarte."
  echo "   (La 1ª vez, macOS te pedirá permiso de GRABAR PANTALLA para la"
  echo "    Terminal: actívalo en Ajustes → Privacidad y seguridad → Grabación"
  echo "    de pantalla, y vuelve a darle Start Session. Es una sola vez.)"
  echo ""
  exec "$CLAUDE" --dangerously-skip-permissions "$PROMPT"
else
  echo "   El Spotter en vivo corre sobre Claude Code (la IA que te vigila la pantalla)."
  echo "   Para activarlo necesitas instalarlo una vez:"
  echo ""
  echo "     1) Ten una cuenta de Claude (claude.ai)"
  echo "     2) Instala Claude Code:  https://claude.ai/code"
  echo "     3) Vuelve a darle a Start Session en la app"
  echo ""
  echo "   Mientras tanto, la plataforma funciona completa sin el Spotter en vivo."
  echo ""
  read -n 1 -s -r -p "   Enter para cerrar…"
fi
