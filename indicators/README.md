# ONE BULLET · Chart Setup

The exact TradingView setup for the One Bullet system — the indicators we actually trade with, plus the color preset that makes them all read as one chart on a black background.

> These are **free community indicators** on TradingView. Add each one from **Indicators → Community Scripts** (search the name), then apply the colors below. We curate the stack + the palette — we don't resell anyone's code (see *Licensing*).

---

## 1 · Chart colors (Settings → Symbol / Canvas)

| Element | Hex |
|---|---|
| Background (solid) | `#0A0A0B` |
| Up candle (body · border · wick) | `#089981` |
| Down candle (body · border · wick) | `#F23645` |
| Grid lines | `#15161A` (or off) |
| Scales / axis text | `#9C988E` |
| Crosshair | `#5B9BD5` |

One Bullet brand accent (used for EMAs / structure below): blue `#3d86cf`.

---

## 2 · The indicator stack

### ① Opening Range with Breakouts & Targets — LuxAlgo
The ORB engine: opening range, ORH/ORL, breakout signals, and range-multiple targets.
- **Time Period / Custom Range:** `0930-0945` (your ORB window), timezone `UTC-5` (New York).
- Up `#089981` · Down `#F23645` · OR levels `#787b86` — matches the candles, no change needed.

### ② EMA 14 / 50 / 200 (trend)
Your trend filter. Recommended recolor for a clean dark chart (instead of the default red/yellow/magenta):
- **EMA 14:** `#3d86cf` (blue) · width 2
- **EMA 50:** `#EDEBE6` (bone) · width 1
- **EMA 200:** `#C9A24B` (amber) · width 2

### ③ ICT Killzones & Pivots — TFO
Sessions + pivots + day/week/month opens.
- Keep the session colors (Asia blue · London red · NY AM green · NY Lunch yellow · NY PM purple) but raise **Box Transparency → 85** so the killzones sit quietly behind price.

### ④ Smart Money Concepts — LuxAlgo
BOS / CHoCH, order blocks, FVGs, EQH/EQL, premium/discount.
- Style **Colored**, bull `#089981` · bear `#F23645`, bullish OB `#3179f5` — already on-palette.
- Turn on only what you use (internal structure + order blocks) to keep it clean.

### ⑤ Fair Value Gap — LuxAlgo
Dedicated FVG with mitigation levels + dashboard.
- Bull `#089981` (70% transp.) · Bear `#F23645` (70%).

---

## 3 · One Bullet Toolkit (optional all-in-one)

`one-bullet-toolkit.pine` — our own Pine v5 overlay, **ours to ship**. It draws:

- **Session liquidity** — the HIGH and LOW of Asia (red), London (blue) and New York (green) as clean lines (no shading). Each untaken level **extends right forever** as live liquidity; the instant price **takes** it, the line **stops** at that bar. Optional labels (AS.H, LO.L, …) ride the right edge.
- **Opening Range** — subtle box during the window, then ORH / ORL solid lines + a dashed midline extending right, labeled.
- **EMAs 14 / 50 / 200** — blue / bone / amber.
- **FVGs** — bullish/bearish imbalances.

Everything is toggle-able in the settings (sessions, how many to keep, hide-once-taken, ORB window, timezone). Use it as a single clean overlay instead of loading all five public indicators above.

---

## Licensing (read this before bundling anything)

- **LuxAlgo** scripts (ORB & Targets, Smart Money Concepts, Fair Value Gap) are **CC BY-NC-SA 4.0 — non-commercial.** One Bullet is a paid product, so we **cannot bundle, resell, or redistribute their code.** We can only point members to the free public versions and share our color/settings preset. Keep the attribution.
- **ICT Killzones & Pivots [TFO]** is **MPL 2.0** — more permissive, but keep the attribution/source.
- The **One Bullet Toolkit** (`one-bullet-toolkit.pine`) is ours — bundle it freely.

Bottom line for the paid product: ship **our toolkit** + this **setup guide**. Link out to the LuxAlgo/ICT scripts; don't repackage them.
