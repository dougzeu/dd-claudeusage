#!/usr/bin/env python3
"""Gera o app icon do dd-claudeusage: sunburst branco num squircle laranja Claude.

Uso:  python make_icon.py   ->  assets/appicon.png (1024x1024)
O .icns é montado depois com sips + iconutil (ver README). Requer Pillow.
"""
import math
import os

from PIL import Image, ImageDraw

S = 1024
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets", "appicon.png")


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


# fundo: gradiente vertical laranja Claude (claro -> escuro)
grad = Image.new("RGB", (S, S))
gd = ImageDraw.Draw(grad)
top, bot = (0xEA, 0xA1, 0x78), (0xBE, 0x53, 0x2F)
for y in range(S):
    gd.line([(0, y), (S, y)], fill=lerp(top, bot, y / S))

# máscara squircle (rounded rect no estilo macOS)
mask = Image.new("L", (S, S), 0)
ImageDraw.Draw(mask).rounded_rectangle([0, 0, S - 1, S - 1], radius=int(S * 0.225), fill=255)

img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
img.paste(grad, (0, 0), mask)

# sunburst branco central: 12 pétalas (losango — fino no centro, largo no meio, pontudo na ponta)
d = ImageDraw.Draw(img)
cx = cy = S / 2
n = 12
r_out, r_mid, w = S * 0.36, S * 0.15, S * 0.052
for k in range(n):
    a = 2 * math.pi * k / n - math.pi / 2
    ca, sa = math.cos(a), math.sin(a)
    pa, ps = math.cos(a + math.pi / 2), math.sin(a + math.pi / 2)  # perpendicular
    tip = (cx + r_out * ca, cy + r_out * sa)
    left = (cx + r_mid * ca + w * pa, cy + r_mid * sa + w * ps)
    right = (cx + r_mid * ca - w * pa, cy + r_mid * sa - w * ps)
    d.polygon([(cx, cy), left, tip, right], fill=(255, 255, 255, 255))

os.makedirs(os.path.dirname(OUT), exist_ok=True)
img.save(OUT)
print("wrote", OUT)
