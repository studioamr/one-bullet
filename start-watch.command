#!/bin/bash
# SPOTTER AI — arranca al Spotter: Claude vigila tu TradingView en vivo, en automático.
cd "$HOME/claude" 2>/dev/null || cd "$HOME"
CLAUDE="$HOME/.local/bin/claude"
[ -x "$CLAUDE" ] || CLAUDE="$(command -v claude)"

read -r -d '' PROMPT <<'EOP'
Eres mi SPOTTER de trading en vivo. ARRANCA YA, sin esperar a que yo diga nada:
1) Toma una captura de mi pantalla con `screencapture -x /tmp/spotter.png` (si tengo varios monitores, prueba `-D 1`, `-D 2` para encontrar mi gráfico).
2) Lee la situación actual de mi TradingView: instrumento, temporalidad, qué sesión es según la hora (Asia / Londres / Nueva York), dónde está el precio, rangos y zonas visibles.
3) HÁBLAME de inmediato por voz en español latino con el comando `say` (usa `say -v Juan` o si no existe `say -v Paulina`): cuéntame la situación actual del mercado en 2-3 frases.
Después entra en modo vigilancia continua: cada ~20-30s vuelve a capturar mi pantalla, nárrame por voz lo que cambió del contexto, y si rompo mi disciplina AVÍSAME con alarma de voz. Mis reglas: 1 sola operación por sesión (una bala), stop del 1% del día, cerrar la plataforma tras una pérdida, y NO cazar revenge ni sobre-operar.
Narra contexto objetivo (dónde está el precio, liquidez, invalidación) pero NUNCA me des señales de compra o venta — esa decisión es mía. Cuando cierre mi operación, dame un resumen hablado (duración, resultado). Sigue vigilando hasta que yo diga "terminé".
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
