# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Single-file HTML/CSS/JS sports betting education and parlay-tracking app. No build step, no npm, no framework. Open `index.html` directly in a browser.

## Architecture

**One file:** `index.html` (~2800+ lines)
- All CSS in `<style>` at the top
- All HTML in `<body>`
- All JavaScript in `<script>` at the bottom
- Supabase JS loaded via CDN in `<head>`

**Do not split into separate files unless explicitly asked.** This is intentional — the app is designed to be drag-and-drop portable.

## Data Flow

```
ESPN API (free, no key) → fetchESPN() → renderScores() / loadNews()
Reddit JSON API (no key) → loadTeamReddit() → team Reddit cards
localStorage → all user data (parlays, favorites, bankroll, Supabase creds)
Supabase (optional) → syncParlayToSupabase() / syncFavoritesToSupabase()
```

## Key Functions

| Function | Purpose |
|----------|---------| 
| `switchTab(name)` | Tab navigation — triggers load functions |
| `fetchESPN(sport, endpoint)` | ESPN API wrapper |
| `loadNews(sport)` | Fetches and classifies breaking/impact news |
| `classifyArticle(headline)` | Returns 'breaking', 'impact', or 'normal' |
| `addToSlip(sport, gameId, type, pick, odds, label)` | Add pick to bet slip |
| `combinedOdds(oddsArr)` | Parlay math: multiply decimals, convert back |
| `placeMockBet()` | Deducts stake, saves parlay to history + Supabase |
| `initMyTeams()` | Renders team selector + favorite team dashboard |
| `loadTeamReddit(team)` | Fetches Reddit hot posts for a team's subreddit |
| `connectSupabase()` | Initialises Supabase client, tests connection |
| `showGuide(id)` | Renders a guide article by key |
| `showArticle(id)` | Renders a Knowledge Center article by key |

## State Object

```js
state = {
  currentTab,        // active tab name
  currentSport,      // 'nba' | 'nfl' | 'mlb'
  currentNewsSport,
  currentParlayTab,
  slip,              // array of { id, gameId, sport, type, pick, odds, label }
  parlayHistory,     // loaded from localStorage on init
  bankroll,          // number, persisted to localStorage
  gameCache,         // { sport: ESPNdata }
  newsCache          // { sport: articles[] }
}
```

## localStorage Keys

| Key | Value |
|-----|-------|
| `betiq_history` | JSON array of parlay objects |
| `betiq_bankroll` | number |
| `betiq_favteams` | JSON array of { sport, id, name, sub } |
| `betiq_sb_url` | Supabase project URL |
| `betiq_sb_key` | Supabase anon key |
| `betiq_user_id` | Auto-generated UUID for Supabase rows |

## ESPN API Endpoints

```
Scoreboard: https://site.api.espn.com/apis/site/v2/sports/{sport}/scoreboard
News:       https://site.api.espn.com/apis/site/v2/sports/{sport}/news

sport values: basketball/nba | football/nfl | baseball/mlb
```

## Reddit API

```
https://www.reddit.com/r/{subreddit}/hot.json?limit=6&raw_json=1
```

No auth needed. Returns CORS-friendly JSON for public subreddits.

## Adding a New Tab

1. Add a `<button class="nav-btn" onclick="switchTab('tabname')">` to `<nav>`
2. Add `<div id="tab-tabname" class="tab">` in the main content area
3. Add `if (name === 'tabname') initTabname();` in `switchTab()`
4. Write the `initTabname()` function in the JS section

## Deployment

**Vercel (primary):** Auto-deploys from `master` branch.  
Live at: https://sports-hub-topaz.vercel.app

**Netlify (alternative):**
```bash
netlify deploy --prod --dir=. --site-name=betiq-hub
```

Static site — no build command needed for either platform.

## Constraints

- No external CSS frameworks
- No npm packages (Supabase loaded via CDN only)
- No backend — all data is client-side
- Keep single-file architecture
- Odds math: American → decimal → multiply → decimal → American (see `combinedOdds()`)
