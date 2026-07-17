#!/usr/bin/env python3
# Fondo del instalador DMG: oscuro, marca SPOTTER AI, flecha app → Aplicaciones.
from PIL import Image, ImageDraw, ImageFont
import math

W, H = 660, 420
S = 2  # supersample
img = Image.new("RGBA", (W*S, H*S), (10, 10, 12, 255))
d = ImageDraw.Draw(img)

ACC = (74, 144, 217)
BONE = (237, 235, 230)
DIM = (156, 152, 142)
FAINT = (95, 92, 85)

# halo azul sutil arriba
halo = Image.new("RGBA", (W*S, H*S), (0,0,0,0))
hd = ImageDraw.Draw(halo)
hd.ellipse([W*S*0.2, -H*S*0.4, W*S*0.8, H*S*0.5], fill=ACC+(26,))
from PIL import ImageFilter
halo = halo.filter(ImageFilter.GaussianBlur(60))
img = Image.alpha_composite(img, halo)
d = ImageDraw.Draw(img)

def font(sz, bold=False):
    paths = [
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial.ttf",
    ]
    for p in paths:
        try: return ImageFont.truetype(p, sz*S)
        except: pass
    return ImageFont.load_default()

def ctext(y, s, fnt, col, ls=0):
    # texto centrado con letter-spacing opcional
    if ls:
        widths=[d.textlength(ch, font=fnt) for ch in s]
        total=sum(widths)+ls*S*(len(s)-1)
        x=(W*S-total)/2
        for ch,w in zip(s,widths):
            d.text((x,y), ch, font=fnt, fill=col); x+=w+ls*S
    else:
        w=d.textlength(s, font=fnt); d.text(((W*S-w)/2,y), s, font=fnt, fill=col)

# marca arriba
ctext(38*S, "SPOTTER AI", font(15, True), BONE, ls=6)
ctext(66*S, "Arrástrala a Aplicaciones para instalar", font(12), DIM)

# flecha centro (de la app hacia Aplicaciones), a la altura del centro de los íconos y~200
ay = 200*S
x0, x1 = 258*S, 400*S
d.line([x0, ay, x1, ay], fill=ACC+(230,), width=5*S)
d.polygon([(x1, ay-13*S),(x1+22*S, ay),(x1, ay+13*S)], fill=ACC+(230,))
# nota al pie: cómo abrirla la 1a vez (método confiable en Sonoma)
ctext(346*S, "¿macOS la bloquea la 1ª vez? Es normal — la app es nueva.", font(10), DIM)
ctext(366*S, "Ábrela en Ajustes del Sistema → Privacidad y seguridad → “Abrir de todos modos”.", font(9), FAINT)

out = img.resize((W, H), Image.LANCZOS)
out.save("dmg-bg.png")
# @2x para retina
img.resize((W*2, H*2), Image.LANCZOS).save("dmg-bg@2x.png")
print("fondo DMG generado:", W, "x", H)
