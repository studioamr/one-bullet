#!/bin/bash
# SPOTTER AI — arranca una sesión de Claude que vigila tu TradingView en vivo.
cd "$HOME/claude" 2>/dev/null || cd "$HOME"
CLAUDE="$HOME/.local/bin/claude"
[ -x "$CLAUDE" ] || CLAUDE="$(command -v claude)"

PROMPT="empieza sesión: vigila mi TradingView en vivo, cada ~20s revisa mi pantalla y avísame con alarma de voz si rompo mi disciplina (1 bala por sesión, stop 1% diario, cerrar tras pérdida, cazar revenge). narra el contexto del precio pero NO me des señales de compra o venta. cuando cierre el trade dame el resumen (duración, resultado). di 'terminé' para parar."

clear
echo ""
echo "   SPOTTER AI — Spotter en línea…"
echo "   (te va a pedir permiso para ver tu pantalla — apruébalo)"
echo ""

if [ -x "$CLAUDE" ]; then
  exec "$CLAUDE" "$PROMPT"
else
  echo "   No encontré el comando 'claude'. Abre un chat de Claude y escribe: empieza sesión"
  echo ""
  read -n 1 -s -r -p "   Enter para cerrar…"
fi
