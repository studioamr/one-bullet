#!/bin/bash
# SPOTTER AI — arranca al Spotter: una sesión de Claude que vigila tu TradingView en vivo.
cd "$HOME/claude" 2>/dev/null || cd "$HOME"
CLAUDE="$HOME/.local/bin/claude"
[ -x "$CLAUDE" ] || CLAUDE="$(command -v claude)"

PROMPT="empieza sesión: vigila mi TradingView en vivo, cada ~20s revisa mi pantalla y avísame con alarma de voz si rompo mi disciplina (1 bala por sesión, stop 1% diario, cerrar tras pérdida, cazar revenge). narra el contexto del precio pero NO me des señales de compra o venta. cuando cierre el trade dame el resumen (duración, resultado). di 'terminé' para parar."

clear
echo ""
echo "   ◉  SPOTTER AI — el Spotter se está conectando…"
echo ""

if [ -n "$CLAUDE" ] && [ -x "$CLAUDE" ]; then
  echo "   Te va a pedir permiso para ver tu pantalla — apruébalo."
  echo "   (verás el indicador naranja arriba: el Spotter está mirando)"
  echo ""
  exec "$CLAUDE" "$PROMPT"
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
