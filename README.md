# BetIQ — Sports Betting Hub

An all-in-one sports hub for fans who want to track scores, follow news, learn sports betting, and practice building parlays — with zero real money required.

**Live:** [Deploy to Netlify](#deployment)

---

## Features

| Tab | What It Does |
|-----|-------------|
| 🏠 Dashboard | Bankroll stats, live games, headlines, platform links |
| 📊 Scores & Stats | Real ESPN data — NBA, NFL, MLB live scores |
| 📰 News | Headlines with auto-detected breaking news & betting impact alerts |
| ⭐ My Teams | Favorite teams dashboard with Reddit feeds per team |
| 🎯 Parlay Builder | Browse real games, click odds to build parlays |
| 📈 My Parlays | History, win/loss settlement, P&L tracking |
| 📚 Knowledge Center | 12 articles: odds, spreads, parlays, EV, bankroll management |
| 🧮 Calculators | Odds converter, payout, parlay, Kelly Criterion, break-even |
| 📖 Guide | Full user manual for every feature |
| ⚙️ Settings | Supabase sync, bankroll reset, data export |

---

## Stack

- **Frontend:** Vanilla HTML/CSS/JS — single file, no build step
- **Data:** ESPN public API (no key required), Reddit public JSON API
- **Storage:** `localStorage` (default) + optional Supabase cloud sync
- **Platforms:** Links to DraftKings, FanDuel, PrizePicks

---

## Running Locally

Just open `index.html` in Chrome or Edge. No install, no server needed.

---

## Supabase Setup (Optional)

Supabase enables cross-device sync of parlays and favorites.

1. Create a free project at [supabase.com](https://supabase.com)
2. Open the SQL Editor and run:

```sql
create table betiq_parlays (
  id text primary key,
  user_id text not null,
  date text,
  legs jsonb,
  stake numeric,
  odds integer,
  payout text,
  result text default 'pending'
);

create table betiq_favorites (
  id text primary key,
  user_id text not null,
  sport text,
  team_id text,
  team_name text,
  team_abbr text,
  subreddit text
);

create table betiq_bankroll (
  user_id text primary key,
  balance numeric default 1000
);
```

3. Copy your **Project URL** and **anon/public key** from Project Settings → API
4. Paste both into the app's **Settings** tab and click Connect

---

## Deployment

### Netlify (recommended)

```bash
npm install -g netlify-cli
netlify login
netlify deploy --prod --dir=. --site-name=betiq-hub
```

### GitHub Pages

Push to GitHub and enable Pages from the repo Settings → Pages → deploy from `main` branch root.

---

## APIs Used

| API | Auth | Usage |
|-----|------|-------|
| ESPN Site API | None | Scores, news for NBA/NFL/MLB |
| Reddit JSON API | None | Team subreddit hot posts |
| Supabase | URL + anon key (user-provided) | Cloud sync |

---

## Disclaimer

BetIQ is an educational and entertainment tool. The virtual bankroll involves no real money. Always gamble responsibly. Check your local laws before placing real bets.
