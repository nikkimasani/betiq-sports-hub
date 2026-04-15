# PRD: BetIQ Sports Betting Hub

## Purpose

An all-in-one sports hub for fans who want to track live scores, follow team news, learn sports betting concepts, and practise building parlays — with zero real money involved. The goal is education and entertainment.

## Users

Sports fans interested in learning how sports betting works without financial risk. Designed for personal or small-group educational use.

## Features

| Tab | Description |
|---|---|
| Dashboard | Bankroll summary, live game snapshot, top headlines, platform links |
| Scores & Stats | Real ESPN data — live scores for NBA, NFL, MLB |
| News | Headlines auto-classified as breaking / betting-impact / normal, per sport |
| My Teams | Favourite team cards with Reddit feed and quick score lookup |
| Parlay Builder | Browse real games, click odds to add legs, calculate combined payout |
| My Parlays | History log with win/loss settlement and P&L tracking |
| Knowledge Center | 12 educational articles: odds, spreads, parlays, EV, bankroll management |
| Calculators | Odds converter, payout, parlay, Kelly Criterion, break-even |
| Guide | Full in-app user manual |
| Settings | Supabase credentials, bankroll reset, data export |

## Technical Constraints

- Single `index.html` file — no framework, no build step, no npm
- Virtual bankroll only — no real money, no payment integration
- Supabase sync is optional; app must work fully with localStorage alone
- ESPN and Reddit APIs require no authentication
- Must remain portable (openable by dragging the file into a browser)

## Deployment

Vercel (primary) — auto-deploys from `master` branch.  
Live at https://sports-hub-topaz.vercel.app

Netlify also supported via `netlify.toml`.
