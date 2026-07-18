#!/bin/bash
# SPOTTER AI — enciende/apaga tu estado EN VIVO (aparece en la app, la landing y Discord).
# Uso por terminal:  ./golive.command kick "https://kick.com/tu-canal" "Sesión de NY en vivo"
#                    ./golive.command off
# O doble clic: te pregunta.
cd "$HOME/claude/candado" 2>/dev/null || cd "$(dirname "$0")"
CONF="live.json"
HOOKFILE=".discord-webhook"   # opcional: pega ahí la URL de tu webhook de Discord (1 línea)

plat="$1"; url="$2"; title="$3"

# modo interactivo (doble clic, sin argumentos)
if [ -z "$plat" ]; then
  echo ""; echo "   SPOTTER AI — EN VIVO"; echo ""
  read -p "   Plataforma (kick/youtube/twitch) o 'off' para apagar: " plat
  if [ "$plat" != "off" ] && [ -n "$plat" ]; then
    read -p "   Link de tu stream: " url
    read -p "   Título: " title
  fi
fi

if [ "$plat" = "off" ] || [ -z "$plat" ]; then
  printf '{"live": false, "platform": "", "url": "", "title": "", "started": ""}\n' > "$CONF"
  echo "   🔴 EN VIVO: APAGADO"
else
  now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '{"live": true, "platform": "%s", "url": "%s", "title": "%s", "started": "%s"}\n' "$plat" "$url" "$title" "$now" > "$CONF"
  echo "   🔴 EN VIVO: $plat · $title"
  if [ -f "$HOOKFILE" ]; then
    hook="$(head -1 "$HOOKFILE")"
    [ -n "$hook" ] && curl -s -H "Content-Type: application/json" -X POST \
      -d "{\"content\":\"🔴 **EN VIVO ahora** — ${title}\\n${url}\"}" "$hook" >/dev/null && echo "   → avisado a Discord"
  fi
fi

# publicar a GitHub Pages para que todos lo vean (~1 min)
git add "$CONF" >/dev/null 2>&1
if git commit -m "live: ${plat:-off}" >/dev/null 2>&1; then
  git push >/dev/null 2>&1 && echo "   → publicado en la web (tarda ~1 min)" || echo "   → commit local hecho, corre git push cuando puedas"
fi
echo ""
[ -z "$1" ] && read -n 1 -s -r -p "   Enter para cerrar…"
