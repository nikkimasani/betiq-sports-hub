# BetIQ Visual Redesign — Design Spec
**Date:** 2026-04-16

## Overview
Full visual redesign of `index.html` — pure CSS/color/font changes only. No layout, tab structure, or functionality changes. Goal: replace generic dark-navy AI-generated look with a distinctive sportsbook identity.

## Design Direction
**The Sportsbook** — pure black base, red-orange accent, Barlow Condensed typography. Aggressive, high-contrast, stadium energy. Inspired by real sportsbook interfaces but distinctive enough to stand out.

## Colors

| Variable | Old | New |
|---|---|---|
| `--bg` | `#0f1923` (navy) | `#0a0a0a` (near-black) |
| `--bg2` | `#1a2634` (navy) | `#111111` |
| `--bg3` | `#1e2d3e` (navy) | `#1a1a1a` |
| `--bg4` | `#243447` (navy) | `#222222` |
| `--accent` (was `--green`) | `#53d22c` (lime) | `#FF3D00` (red-orange) |
| `--gold` | `#ffc940` | `#FFB800` |
| `--red` | `#e44d4d` | `#FF3B3B` |
| `--border` | `#2a3f55` (navy-tinted) | `#222222` |
| `--text2` | `#8fa3b4` (blue-grey) | `#888888` |
| `--text3` | `#506070` (blue-grey) | `#444444` |

Remove navy/blue tint from all backgrounds. Every surface is true black or dark grey.

## Typography

Add to `<head>`:
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
```

- `body`: `font-family: 'Inter', -apple-system, sans-serif`
- Logo, nav labels, score numbers, odds values, team names, section headers: `font-family: 'Barlow Condensed', sans-serif`

## Key Component Changes

**Header**
- Background: `#111`
- Bottom border: `2px solid #FF3D00`
- Logo: Barlow Condensed 800, `Bet<span style="color:#FF3D00">IQ</span>`
- Bankroll badge: `#1a1a1a` bg, `#FF3D00` text for amount

**Nav tabs**
- Active tab: `color: #FF3D00`, `border-bottom: 3px solid #FF3D00`
- Labels: Barlow Condensed 700 uppercase

**Score cards**
- Base: `#111` bg, `#222` border
- Live score (winning team): `color: #FF3D00`
- LIVE badge: `#FF3D00` text
- Sport label badges: keep NBA blue / NFL red / MLB gold color coding

**Odds buttons**
- Selected: `background: #FF3D00`, `color: #fff`
- Unselected: `background: #1a1a1a`, `border: 1px solid #222`

**Bet slip sidebar**
- Background: `#111`
- "Place Bet" CTA: `background: #FF3D00`, `color: #fff`, Barlow Condensed 800

**Score/stat numbers throughout**
- Apply `font-family: 'Barlow Condensed'` to all score values, odds numbers, bankroll amounts, percentages

## What Doesn't Change
- Tab structure and navigation
- Layout (header + top nav + main + right bet slip)
- All JavaScript and data logic
- ESPN/Reddit API calls
- Supabase integration
- All tab content and functionality
