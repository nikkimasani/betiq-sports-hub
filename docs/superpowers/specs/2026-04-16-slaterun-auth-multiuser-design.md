# SlateRun — Auth + Multi-User Design Spec
**Date:** 2026-04-16

## Overview
Transform BetIQ Sports Hub into SlateRun — a fully authenticated, multi-user sports betting tracker where every user's data is private to their profile. Uses Supabase Auth (email/password). Admin account (`nikkimasani@gmail.com`) gets a read-only user management panel.

Single-file HTML/CSS/JS architecture is maintained throughout.

---

## 1. Branding Changes

| Old | New |
|---|---|
| `BetIQ` (all occurrences in HTML content) | `SlateRun` |
| `<title>BetIQ — Sports Betting Hub</title>` | `<title>SlateRun — Sports Betting Hub</title>` |
| Logo: `Bet<span>IQ</span>` | `SLATE<span style="color:var(--accent)">RUN</span>` — Barlow Condensed 800 |
| localStorage prefix `betiq_` | `sr_` |
| `betiq_user_id` localStorage key | Removed — replaced by Supabase Auth session |
| `betiq_sb_url` / `betiq_sb_key` localStorage keys | Removed — Supabase connection hardcoded |

Auth overlay tagline: **"Your bets. Your edge."**

---

## 2. Auth System

### Supabase Connection
Replace user-configured Supabase credentials (currently stored in localStorage and entered in Settings) with a single hardcoded connection at the top of the `<script>` block:

```js
const SUPABASE_URL = 'https://<project>.supabase.co';
const SUPABASE_ANON_KEY = '<anon-key>';
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
const ADMIN_EMAIL = 'nikkimasani@gmail.com';
```

### App Init Flow
```
page load
  → sb.auth.getSession()
  → session exists?  YES → loadUser() → initApp()
                     NO  → showAuthOverlay()
```

### Auth Overlay — Split Panel B
Full-screen fixed overlay (`z-index: 500`) blocking the entire app.

**Left panel** (`width: 42%`, `background: var(--accent)`):
- `SLATE` in white, `RUN` in black — Barlow Condensed 900
- Tagline: "Your bets. Your edge." in small uppercase
- Red-orange gradient background

**Right panel** (remaining width, `background: #111`):
- Toggle: "Sign In" / "Create Account" (text links, not tabs)
- Fields: Email, Password (+ Display Name on Create Account only)
- CTA button: `SIGN IN →` / `CREATE ACCOUNT →` — solid red-orange, Barlow Condensed, white text
- Error message area below button (red text, `var(--red)`)

### Sign In
```js
sb.auth.signInWithPassword({ email, password })
```
On success: hide overlay, call `loadUser()` → `initApp()`.

### Create Account
```js
sb.auth.signUp({ email, password })
// then insert into sr_profiles:
sb.from('sr_profiles').insert({ id: user.id, display_name, role: 'user' })
```
After signup: show first-time profile modal (pre-filled display name, confirm button) → then `initApp()`.

### Session Persistence
```js
sb.auth.onAuthStateChange((event, session) => {
  if (event === 'SIGNED_OUT') showAuthOverlay();
  if (event === 'SIGNED_IN') hideAuthOverlay();
});
```

### Profile Pill (Header)
Replaces nothing — added to the right side of the header, left of the bankroll badge:

```html
<div class="profile-pill" onclick="toggleProfileMenu()">
  <div class="profile-avatar">N</div>  <!-- user's first initial -->
  <span class="profile-name">Nikki</span>  <!-- first word of display_name -->
</div>
```

Clicking shows a small dropdown with "Sign Out" only. Sign out calls `sb.auth.signOut()`.

### CSS additions
```css
.profile-pill { display:flex; align-items:center; gap:8px; cursor:pointer; padding:4px 10px; border-radius:20px; background:var(--bg3); border:1px solid var(--border); }
.profile-avatar { width:28px; height:28px; border-radius:50%; background:var(--accent); color:#fff; font-family:'Barlow Condensed',sans-serif; font-weight:800; font-size:14px; display:flex; align-items:center; justify-content:center; }
.profile-name { font-size:13px; font-weight:600; color:var(--text); }
.profile-dropdown { position:absolute; top:52px; right:16px; background:var(--bg2); border:1px solid var(--border); border-radius:8px; padding:4px; z-index:200; }
.profile-dropdown-item { padding:8px 16px; font-size:13px; cursor:pointer; border-radius:5px; }
.profile-dropdown-item:hover { background:var(--bg3); color:var(--red); }
```

---

## 3. Data Layer

### New Table: `sr_profiles`
```sql
create table sr_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  role text not null default 'user',
  created_at timestamptz default now()
);
```

### RLS Policies

**`betiq_parlays`:**
```sql
alter table betiq_parlays enable row level security;
create policy "users see own parlays" on betiq_parlays
  for all using (auth.uid() = user_id OR auth.email() = 'nikkimasani@gmail.com');
```

**`betiq_favorites`:**
```sql
alter table betiq_favorites enable row level security;
create policy "users see own favorites" on betiq_favorites
  for all using (auth.uid() = user_id OR auth.email() = 'nikkimasani@gmail.com');
```

**`betiq_bankroll`:**
```sql
alter table betiq_bankroll enable row level security;
create policy "users see own bankroll" on betiq_bankroll
  for all using (auth.uid() = user_id OR auth.email() = 'nikkimasani@gmail.com');
```

**`sr_profiles`:**
```sql
alter table sr_profiles enable row level security;
create policy "users see own profile" on sr_profiles
  for select using (auth.uid() = id OR auth.email() = 'nikkimasani@gmail.com');
create policy "users update own profile" on sr_profiles
  for update using (auth.uid() = id);
create policy "users insert own profile" on sr_profiles
  for insert with check (auth.uid() = id);
```

### Data Flow Rewrite

**All data functions** replace `state.userId` (random UUID) with `(await sb.auth.getUser()).data.user.id`.

**localStorage** prefix changes from `betiq_` to `sr_` and is used only as a cache:
- Write to Supabase first, then write to localStorage
- On app load, paint from localStorage instantly, then fetch from Supabase and reconcile

**Removed from Settings tab:** Supabase URL/key input fields (connection is now hardcoded). Settings tab keeps: bankroll reset, data export.

**localStorage keys after migration:**

| Old key | New key | Purpose |
|---|---|---|
| `betiq_history` | `sr_history_${userId}` | Parlay history cache |
| `betiq_bankroll` | `sr_bankroll_${userId}` | Bankroll cache |
| `betiq_favteams` | `sr_favteams_${userId}` | Favorite teams cache |
| `betiq_user_id` | — | Removed |
| `betiq_sb_url` | — | Removed |
| `betiq_sb_key` | — | Removed |

Existing anonymous data rows in Supabase (random UUID user_ids) are orphaned — not migrated, not deleted.

---

## 4. Admin Panel

Rendered only when `user.email === ADMIN_EMAIL` (`nikkimasani@gmail.com`).

Nav tab: `⚙ Admin` — added after the existing Settings tab, hidden via `display:none` for non-admin users.

**Content:**
- **Summary row**: Total registered users | Total parlays | Combined P&L across all users
- **User table** (read-only):

| Display Name | Email | Joined | Bankroll | Parlays | Win/Loss |
|---|---|---|---|---|---|

Data fetched via:
```js
// RLS admin policy allows admin to read all rows
const { data: profiles } = await sb.from('sr_profiles').select('*');
const { data: bankrolls } = await sb.from('betiq_bankroll').select('*');
const { data: parlays } = await sb.from('betiq_parlays').select('*');
```

No editing, no deleting. Read-only audit view.

---

## 5. What Doesn't Change
- All tab content and functionality (Scores, News, Parlay Builder, My Parlays, Social, Data Agent, Kalshi, Knowledge, Calculators, Guide, Practice)
- ESPN API calls
- Reddit API calls
- Layout (header + nav + main + right bet slip)
- All CSS variables and sportsbook visual theme
- Single-file architecture

---

## SQL Migration Script (run in Supabase SQL editor)
```sql
-- 1. Create profiles table
create table if not exists sr_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  role text not null default 'user',
  created_at timestamptz default now()
);

-- 2. Enable RLS on existing tables
alter table betiq_parlays enable row level security;
alter table betiq_favorites enable row level security;
alter table betiq_bankroll enable row level security;
alter table sr_profiles enable row level security;

-- 3. RLS policies
create policy "own_parlays" on betiq_parlays for all
  using (auth.uid() = user_id OR auth.email() = 'nikkimasani@gmail.com');

create policy "own_favorites" on betiq_favorites for all
  using (auth.uid() = user_id OR auth.email() = 'nikkimasani@gmail.com');

create policy "own_bankroll" on betiq_bankroll for all
  using (auth.uid() = user_id OR auth.email() = 'nikkimasani@gmail.com');

create policy "profiles_select" on sr_profiles for select
  using (auth.uid() = id OR auth.email() = 'nikkimasani@gmail.com');

create policy "profiles_insert" on sr_profiles for insert
  with check (auth.uid() = id);

create policy "profiles_update" on sr_profiles for update
  using (auth.uid() = id);
```
