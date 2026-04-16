# SlateRun Auth + Multi-User Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform BetIQ into SlateRun — a fully authenticated multi-user sports betting tracker with Supabase Auth, per-user data isolation, and an admin panel.

**Architecture:** Single-file `index.html` (HTML/CSS/JS). Supabase Auth (email/password) gates the entire app. All data reads/writes use `auth.uid()` via a hardcoded Supabase client `sb`. localStorage serves as a per-user cache with `sr_` prefix. Admin email `nikkimasani@gmail.com` gets a read-only user management tab.

**Tech Stack:** Vanilla HTML/CSS/JS, Supabase JS v2 (CDN), Google Fonts (already loaded)

---

## File Structure

Single file: `index.html`
- `<head>` lines 1–11: add hardcoded Supabase constants
- `<style>` block: add auth overlay CSS + profile pill CSS
- `<body>` auth overlay: new `#auth-overlay` div before `<header>`
- `<body>` header: add profile pill + dropdown to right side
- `<body>` nav: add Admin tab (hidden by default)
- `<body>` tab content: add `#tab-admin` div
- `<script>` block: replace `SB_USER`/`sbClient` pattern with `sb`/`state.user`; add auth functions; add admin functions

---

### Task 1: Rebrand BetIQ → SlateRun

**Files:**
- Modify: `index.html` (title, logo, all text references, localStorage keys, User-Agent)

- [ ] **Step 1: Update `<title>` and logo**

Replace:
```html
<title>BetIQ — Sports Betting Hub</title>
```
With:
```html
<title>SlateRun — Sports Betting Hub</title>
```

Find the logo element (search for `class="logo"`) and replace its content:
```html
<!-- Old -->
<div class="logo">Bet<span>IQ</span></div>
<!-- New -->
<div class="logo">SLATE<span>RUN</span></div>
```

- [ ] **Step 2: Replace all "BetIQ" text references in HTML content**

Use Edit with `replace_all: true`:
```
old_string: "BetIQ"
new_string: "SlateRun"
```

This covers guide articles, the user manual, Kalshi guide, prediction tab descriptions.

- [ ] **Step 3: Update Reddit User-Agent header**

```
old_string: "'BetIQ/1.0'"
new_string: "'SlateRun/1.0'"
```

- [ ] **Step 4: Update localStorage key strings in JS**

Use `replace_all: true` for each:
```
old: 'betiq_history'  →  new: 'sr_history'
old: 'betiq_bankroll'  →  new: 'sr_bankroll'
old: 'betiq_favteams'  →  new: 'sr_favteams'
```

Note: `betiq_user_id`, `betiq_sb_url`, `betiq_sb_key` will be removed in Task 2 — do NOT rename them here.

- [ ] **Step 5: Verify**

Open `index.html` in a browser. Confirm:
- Tab title shows "SlateRun — Sports Betting Hub"
- Header logo shows "SLATERUN" (IQ span → RUN span)
- No visible "BetIQ" text anywhere in the app

- [ ] **Step 6: Commit**
```bash
git add index.html
git commit -m "feat: rebrand BetIQ to SlateRun"
```

---

### Task 2: Hardcode Supabase Connection + Remove User-Configured Setup

**Files:**
- Modify: `index.html` (~line 3366 in `<script>`)

This task replaces the user-entered Supabase URL/key pattern with a single hardcoded `sb` client and removes the Settings tab Supabase config section.

- [ ] **Step 1: Add hardcoded Supabase constants at top of `<script>` block**

At the very top of the `<script>` section (before `const state = {`), add:
```js
const SUPABASE_URL = 'https://YOUR_PROJECT.supabase.co'; // replace with real URL
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY'; // replace with real anon key
const ADMIN_EMAIL = 'nikkimasani@gmail.com';
const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

- [ ] **Step 2: Remove the old SB_USER constant and sbClient variable**

Find and delete these lines (~3366–3372):
```js
let sbClient = null;
const SB_USER = localStorage.getItem('betiq_user_id') || (() => {
  const id = crypto.randomUUID();
  localStorage.setItem('betiq_user_id', id);
  return id;
})();
```

- [ ] **Step 3: Remove `connectSupabase()` and `disconnectSupabase()` functions**

Find and delete the entire `connectSupabase()` function (~lines 3373–3394) and `disconnectSupabase()` function (~lines 3395–3400).

- [ ] **Step 4: Add `syncBankrollToSupabase()` as a standalone function**

The bankroll sync was inside `connectSupabase()`. Add it as a standalone function after where `syncFavoritesToSupabase()` ends:
```js
async function syncBankrollToSupabase() {
  if (!sb || !state.user) return;
  try { await sb.from('betiq_bankroll').upsert({ user_id: state.user.id, balance: state.bankroll }); } catch(e) {}
}
```

- [ ] **Step 5: Remove Supabase config section from Settings tab HTML**

Find the Settings tab HTML section that contains the Supabase URL/key inputs and Connect/Disconnect buttons (search for `betiq_sb_url` or `connectSupabase` in the HTML body). Delete the entire Supabase config card from the Settings tab.

Also delete the `initSettings()` code that reads `betiq_sb_url`/`betiq_sb_key` from localStorage (~lines 3718–3731) and replace with a no-op or remove the localStorage reads from it.

- [ ] **Step 6: Verify**

Open browser console. Confirm `sb` is defined:
```js
// In console:
console.log(sb)
// Expected: Supabase client object (not undefined/null)
```

- [ ] **Step 7: Commit**
```bash
git add index.html
git commit -m "feat: hardcode Supabase client, remove user-configured connection"
```

---

### Task 3: Auth Overlay HTML + CSS

**Files:**
- Modify: `index.html` (add CSS to `<style>` block; add HTML before `<header>`)

- [ ] **Step 1: Add auth overlay CSS**

Add to the end of the `<style>` block (before `</style>`):
```css
/* AUTH OVERLAY */
.auth-overlay { position:fixed; inset:0; z-index:500; display:flex; }
.auth-overlay.hidden { display:none; }
.auth-left { width:42%; background:var(--accent); display:flex; align-items:center; justify-content:center; flex-direction:column; padding:40px; }
.auth-right { flex:1; background:#111; display:flex; align-items:center; justify-content:center; }
.auth-logo { font-family:'Barlow Condensed',sans-serif; font-size:48px; font-weight:900; letter-spacing:4px; color:#fff; line-height:1; }
.auth-logo span { color:#000; }
.auth-tagline { font-size:11px; color:rgba(0,0,0,0.45); letter-spacing:3px; text-transform:uppercase; margin-top:10px; }
.auth-box { width:100%; max-width:320px; padding:0 32px; }
.auth-toggle { display:flex; gap:12px; align-items:center; margin-bottom:28px; }
.auth-toggle-item { font-size:14px; font-weight:600; color:var(--text3); cursor:pointer; transition:color .2s; }
.auth-toggle-item.active { color:var(--text); }
.auth-toggle-sep { color:var(--text3); }
.auth-input { width:100%; background:var(--bg3); border:1px solid var(--border); border-radius:6px; padding:11px 14px; color:var(--text); font-size:14px; margin-bottom:10px; display:block; font-family:inherit; }
.auth-input:focus { outline:none; border-color:var(--accent); }
.auth-btn { width:100%; background:var(--accent); color:#fff; border:none; border-radius:6px; padding:13px; font-family:'Barlow Condensed',sans-serif; font-size:15px; font-weight:800; letter-spacing:2px; cursor:pointer; margin-top:4px; transition:background .2s; }
.auth-btn:hover { background:var(--accent2); }
.auth-error { font-size:12px; color:var(--red); margin-top:10px; min-height:18px; }

/* PROFILE PILL */
.profile-pill { display:flex; align-items:center; gap:8px; cursor:pointer; padding:4px 12px 4px 4px; border-radius:20px; background:var(--bg3); border:1px solid var(--border); position:relative; }
.profile-avatar { width:28px; height:28px; border-radius:50%; background:var(--accent); color:#fff; font-family:'Barlow Condensed',sans-serif; font-weight:800; font-size:14px; display:flex; align-items:center; justify-content:center; }
.profile-name { font-size:13px; font-weight:600; color:var(--text); }
.profile-dropdown { position:absolute; top:calc(100% + 8px); right:0; background:var(--bg2); border:1px solid var(--border); border-radius:8px; padding:4px; z-index:200; min-width:130px; display:none; }
.profile-dropdown.open { display:block; }
.profile-dropdown-item { padding:9px 16px; font-size:13px; cursor:pointer; border-radius:5px; color:var(--text2); transition:all .15s; }
.profile-dropdown-item:hover { background:var(--bg3); color:var(--red); }
```

- [ ] **Step 2: Add auth overlay HTML**

Add this HTML immediately after `<body>` and before `<header>`:
```html
<div id="auth-overlay" class="auth-overlay">
  <div class="auth-left">
    <div class="auth-logo">SLATE<span>RUN</span></div>
    <div class="auth-tagline">Your bets. Your edge.</div>
  </div>
  <div class="auth-right">
    <div class="auth-box">
      <div class="auth-toggle">
        <span id="auth-tab-signin" class="auth-toggle-item active" onclick="authShowSignIn()">Sign In</span>
        <span class="auth-toggle-sep">·</span>
        <span id="auth-tab-signup" class="auth-toggle-item" onclick="authShowSignUp()">Create Account</span>
      </div>
      <div id="auth-form-signin">
        <input id="auth-email" type="email" class="auth-input" placeholder="Email">
        <input id="auth-password" type="password" class="auth-input" placeholder="Password">
        <button class="auth-btn" onclick="authSignIn()">SIGN IN →</button>
        <div id="auth-error-signin" class="auth-error"></div>
      </div>
      <div id="auth-form-signup" style="display:none">
        <input id="auth-name" type="text" class="auth-input" placeholder="Display Name">
        <input id="auth-signup-email" type="email" class="auth-input" placeholder="Email">
        <input id="auth-signup-password" type="password" class="auth-input" placeholder="Password (min 6 chars)">
        <button class="auth-btn" onclick="authSignUp()">CREATE ACCOUNT →</button>
        <div id="auth-error-signup" class="auth-error"></div>
      </div>
    </div>
  </div>
</div>
```

- [ ] **Step 3: Add profile pill to header**

Find the header HTML. It currently has the logo on the left and bankroll badge on the right. Replace the right side to wrap bankroll + add profile pill:

Find (approximately):
```html
<div class="bankroll-badge" onclick="openBankrollModal()">
```

Wrap it in a flex container and add the profile pill after it:
```html
<div style="display:flex;align-items:center;gap:10px;position:relative">
  <div class="bankroll-badge" onclick="openBankrollModal()">
    <!-- existing bankroll badge content unchanged -->
  </div>
  <div class="profile-pill" onclick="toggleProfileMenu()">
    <div class="profile-avatar" id="profile-pill-avatar">?</div>
    <span class="profile-name" id="profile-pill-name">...</span>
  </div>
  <div id="profile-dropdown" class="profile-dropdown">
    <div class="profile-dropdown-item" onclick="authSignOut()">Sign Out</div>
  </div>
</div>
```

- [ ] **Step 4: Add Admin nav tab**

In the `<nav>` section, add after the last existing nav button:
```html
<button class="nav-btn" id="nav-admin" onclick="switchTab('admin')" style="display:none">⚙ Admin</button>
```

- [ ] **Step 5: Add Admin tab content div**

In the main content area, after the last existing `<div class="tab" id="tab-...">`, add:
```html
<div id="tab-admin" class="tab"></div>
```

- [ ] **Step 6: Verify (visual only)**

Open `index.html`. Confirm:
- The auth overlay is visible and covers the entire page (Split Panel: red-orange left, dark right)
- The "SLATERUN" logo appears in the left panel in white/black
- Email, password fields and "SIGN IN →" button are visible on the right
- The main app is hidden behind the overlay

- [ ] **Step 7: Commit**
```bash
git add index.html
git commit -m "feat: add auth overlay and profile pill HTML/CSS"
```

---

### Task 4: Auth JavaScript

**Files:**
- Modify: `index.html` (`<script>` block)

- [ ] **Step 1: Update `state` object — remove localStorage reads, add `user: null`**

Find the `const state = {` declaration. Update it to remove the per-user localStorage reads (these will be loaded after auth instead):

Old:
```js
const state = {
  ...
  parlayHistory: JSON.parse(localStorage.getItem('sr_history') || '[]'),
  bankroll: parseFloat(localStorage.getItem('sr_bankroll') || '1000'),
  ...
```

New:
```js
const state = {
  ...
  parlayHistory: [],
  bankroll: 1000,
  user: null,
  ...
```

- [ ] **Step 2: Update `favTeams` initialization**

Find:
```js
let favTeams = JSON.parse(localStorage.getItem('sr_favteams') || '[]').map(({sub, ...t}) => t);
```

Replace with:
```js
let favTeams = [];
```

- [ ] **Step 3: Add all auth functions**

Add this block in the `<script>` section, near the Supabase constants (after the `sb` declaration):

```js
// ── AUTH ──────────────────────────────────────────────────────────────────

async function initAuth() {
  const { data: { session } } = await sb.auth.getSession();
  if (session) {
    await loadUser(session.user);
  } else {
    document.getElementById('auth-overlay').classList.remove('hidden');
  }
  sb.auth.onAuthStateChange(async (event, session) => {
    if (event === 'SIGNED_OUT') {
      state.user = null;
      document.getElementById('auth-overlay').classList.remove('hidden');
    }
    if (event === 'SIGNED_IN' && session) {
      await loadUser(session.user);
    }
  });
}

async function loadUser(user) {
  const { data: profile } = await sb.from('sr_profiles').select('*').eq('id', user.id).single();
  const displayName = profile?.display_name || user.email.split('@')[0];
  state.user = { id: user.id, email: user.email, name: displayName };
  // Load user-specific localStorage data
  state.parlayHistory = JSON.parse(localStorage.getItem(`sr_history_${user.id}`) || '[]');
  state.bankroll = parseFloat(localStorage.getItem(`sr_bankroll_${user.id}`) || '1000');
  favTeams = JSON.parse(localStorage.getItem(`sr_favteams_${user.id}`) || '[]');
  // Update profile pill
  document.getElementById('profile-pill-avatar').textContent = displayName[0].toUpperCase();
  document.getElementById('profile-pill-name').textContent = displayName.split(' ')[0];
  // Show admin tab if admin
  document.getElementById('nav-admin').style.display = user.email === ADMIN_EMAIL ? 'inline-block' : 'none';
  // Hide overlay and start app
  document.getElementById('auth-overlay').classList.add('hidden');
  initApp();
}

function authShowSignIn() {
  document.getElementById('auth-form-signin').style.display = 'block';
  document.getElementById('auth-form-signup').style.display = 'none';
  document.getElementById('auth-tab-signin').classList.add('active');
  document.getElementById('auth-tab-signup').classList.remove('active');
  document.getElementById('auth-error-signin').textContent = '';
}

function authShowSignUp() {
  document.getElementById('auth-form-signin').style.display = 'none';
  document.getElementById('auth-form-signup').style.display = 'block';
  document.getElementById('auth-tab-signin').classList.remove('active');
  document.getElementById('auth-tab-signup').classList.add('active');
  document.getElementById('auth-error-signup').textContent = '';
}

async function authSignIn() {
  const email = document.getElementById('auth-email').value.trim();
  const password = document.getElementById('auth-password').value;
  const errEl = document.getElementById('auth-error-signin');
  errEl.textContent = '';
  if (!email || !password) { errEl.textContent = 'Email and password required.'; return; }
  const btn = document.querySelector('#auth-form-signin .auth-btn');
  btn.textContent = 'SIGNING IN...'; btn.disabled = true;
  const { error } = await sb.auth.signInWithPassword({ email, password });
  btn.textContent = 'SIGN IN →'; btn.disabled = false;
  if (error) errEl.textContent = error.message;
}

async function authSignUp() {
  const name = document.getElementById('auth-name').value.trim();
  const email = document.getElementById('auth-signup-email').value.trim();
  const password = document.getElementById('auth-signup-password').value;
  const errEl = document.getElementById('auth-error-signup');
  errEl.textContent = '';
  if (!name || !email || !password) { errEl.textContent = 'All fields required.'; return; }
  if (password.length < 6) { errEl.textContent = 'Password must be at least 6 characters.'; return; }
  const btn = document.querySelector('#auth-form-signup .auth-btn');
  btn.textContent = 'CREATING...'; btn.disabled = true;
  const { data, error } = await sb.auth.signUp({ email, password });
  btn.textContent = 'CREATE ACCOUNT →'; btn.disabled = false;
  if (error) { errEl.textContent = error.message; return; }
  if (data.user) {
    await sb.from('sr_profiles').insert({ id: data.user.id, display_name: name, email, role: 'user' });
  }
}

function toggleProfileMenu() {
  document.getElementById('profile-dropdown').classList.toggle('open');
}

async function authSignOut() {
  document.getElementById('profile-dropdown').classList.remove('open');
  await sb.auth.signOut();
}
```

- [ ] **Step 4: Replace DOMContentLoaded init call**

Find the existing `document.addEventListener('DOMContentLoaded', ...)` or `window.onload` that calls the main init function. Replace whatever init call exists with:

```js
document.addEventListener('DOMContentLoaded', initAuth);
```

`initAuth` will call `loadUser()` → `initApp()` after auth succeeds. Remove any existing direct `initApp()` call from DOMContentLoaded.

- [ ] **Step 5: Verify sign-in flow**

Open `index.html`. Confirm:
1. Auth overlay appears on load
2. Clicking "Create Account" toggles to the signup form with Name field
3. Signing up with a test email creates the account (check Supabase Auth dashboard)
4. After signup, overlay disappears and app loads
5. Signing out shows the overlay again
6. Signing back in with the same credentials works

- [ ] **Step 6: Commit**
```bash
git add index.html
git commit -m "feat: add Supabase Auth sign-in/sign-up flow"
```

---

### Task 5: Data Layer — Wire Auth User ID

**Files:**
- Modify: `index.html` (`<script>` block — Supabase sync functions and localStorage writes)

- [ ] **Step 1: Replace all `sbClient` references with `sb`**

Use Edit with `replace_all: true`:
```
old_string: "sbClient"
new_string: "sb"
```

- [ ] **Step 2: Replace all `SB_USER` references with `state.user.id`**

Use Edit with `replace_all: true`:
```
old_string: "SB_USER"
new_string: "state.user.id"
```

- [ ] **Step 3: Update guard clause in sync functions**

All sync functions currently have `if (!sb) return;`. Update to also guard on user:

Use Edit with `replace_all: true`:
```
old_string: "if (!sb) return;"
new_string: "if (!sb || !state.user) return;"
```

- [ ] **Step 4: Update localStorage writes to use per-user keys**

Find every `localStorage.setItem('sr_history', ...)` and `localStorage.setItem('sr_bankroll', ...)` and `localStorage.setItem('sr_favteams', ...)` throughout the script.

Replace each with the user-suffixed version:

```js
// OLD
localStorage.setItem('sr_history', JSON.stringify(state.parlayHistory));
// NEW
localStorage.setItem(`sr_history_${state.user.id}`, JSON.stringify(state.parlayHistory));

// OLD
localStorage.setItem('sr_bankroll', state.bankroll.toString());
// NEW
localStorage.setItem(`sr_bankroll_${state.user.id}`, state.bankroll.toString());

// OLD
localStorage.setItem('sr_favteams', JSON.stringify(favTeams));
// NEW
localStorage.setItem(`sr_favteams_${state.user.id}`, JSON.stringify(favTeams));
```

Use Edit for each occurrence (there will be ~5–6 occurrences total across the file).

- [ ] **Step 5: Update localStorage reads in reset/clear functions**

Find any `localStorage.removeItem('sr_history')` or `localStorage.removeItem('sr_bankroll')` (in the bankroll reset / data export functions) and update them to use the user-suffixed key:

```js
// OLD
localStorage.removeItem('sr_history');
// NEW
localStorage.removeItem(`sr_history_${state.user.id}`);
```

- [ ] **Step 6: Call `syncBankrollToSupabase()` when bankroll changes**

Find the function that sets `state.bankroll` and saves to localStorage (the bankroll update function). Add a call to `syncBankrollToSupabase()` after the localStorage write:

```js
localStorage.setItem(`sr_bankroll_${state.user.id}`, state.bankroll.toString());
syncBankrollToSupabase();
```

- [ ] **Step 7: Verify per-user data isolation**

Open `index.html`. Sign in as User A:
1. Place a mock parlay — confirm it appears in My Parlays tab
2. Sign out
3. Create a new account (User B) — confirm My Parlays tab is empty
4. Sign out, sign back in as User A — confirm original parlay is still there

- [ ] **Step 8: Commit**
```bash
git add index.html
git commit -m "feat: wire all data operations to authenticated user ID"
```

---

### Task 6: Admin Panel

**Files:**
- Modify: `index.html` (`<script>` block — add `initAdmin()`)

- [ ] **Step 1: Add `initAdmin()` to the `switchTab()` function**

Find the `switchTab(name)` function. Add this case:
```js
if (name === 'admin') initAdmin();
```

- [ ] **Step 2: Add `initAdmin()` function**

Add this function in the `<script>` block:

```js
async function initAdmin() {
  if (!state.user || state.user.email !== ADMIN_EMAIL) return;
  const container = document.getElementById('tab-admin');
  container.innerHTML = '<div class="loading"><div class="spinner"></div><p>Loading users...</p></div>';

  const [{ data: profiles }, { data: bankrolls }, { data: parlays }] = await Promise.all([
    sb.from('sr_profiles').select('*').order('created_at'),
    sb.from('betiq_bankroll').select('*'),
    sb.from('betiq_parlays').select('*')
  ]);

  const bankrollMap = {};
  (bankrolls || []).forEach(b => { bankrollMap[b.user_id] = b.balance; });

  const parlayCounts = {}, parlayWins = {};
  (parlays || []).forEach(p => {
    parlayCounts[p.user_id] = (parlayCounts[p.user_id] || 0) + 1;
    if (p.result === 'win') parlayWins[p.user_id] = (parlayWins[p.user_id] || 0) + 1;
  });

  const totalPnl = (parlays || []).reduce((sum, p) => {
    if (p.result === 'win') return sum + ((p.payout || 0) - (p.stake || 0));
    if (p.result === 'loss') return sum - (p.stake || 0);
    return sum;
  }, 0);

  const rows = (profiles || []).map(p => {
    const bank = typeof bankrollMap[p.id] === 'number' ? `$${bankrollMap[p.id].toFixed(2)}` : '—';
    const count = parlayCounts[p.id] || 0;
    const wins = parlayWins[p.id] || 0;
    const tag = p.id === state.user.id ? ' <span style="color:var(--accent);font-size:10px">YOU</span>' : '';
    return `<tr>
      <td>${p.display_name}${tag}</td>
      <td style="color:var(--text2)">${p.email}</td>
      <td style="color:var(--text3)">${new Date(p.created_at).toLocaleDateString()}</td>
      <td>${bank}</td>
      <td>${count}</td>
      <td>${wins}W / ${count - wins}L</td>
    </tr>`;
  }).join('');

  const pnlColor = totalPnl >= 0 ? 'var(--accent)' : 'var(--red)';
  container.innerHTML = `
    <div class="section-header"><div class="section-title">Admin Panel</div></div>
    <div class="dashboard-grid" style="grid-template-columns:repeat(3,1fr);margin-bottom:20px">
      <div class="stat-card"><div class="stat-label">Total Users</div><div class="stat-value">${profiles?.length || 0}</div></div>
      <div class="stat-card"><div class="stat-label">Total Parlays</div><div class="stat-value">${parlays?.length || 0}</div></div>
      <div class="stat-card"><div class="stat-label">Combined P&amp;L</div><div class="stat-value" style="color:${pnlColor}">${totalPnl >= 0 ? '+' : ''}$${Math.abs(totalPnl).toFixed(2)}</div></div>
    </div>
    <div class="card" style="overflow-x:auto">
      <table class="tracker-table">
        <thead><tr>
          <th>Name</th><th>Email</th><th>Joined</th><th>Bankroll</th><th>Parlays</th><th>Record</th>
        </tr></thead>
        <tbody>${rows || '<tr><td colspan="6" style="color:var(--text3);text-align:center">No users yet</td></tr>'}</tbody>
      </table>
    </div>`;
}
```

- [ ] **Step 3: Verify admin panel**

Sign in as `nikkimasani@gmail.com`. Confirm:
1. "⚙ Admin" tab is visible in the nav
2. Clicking it loads the user table with summary stats
3. Your own row is marked with the "YOU" tag
4. Sign in as a different account — confirm Admin tab is NOT visible

- [ ] **Step 4: Commit**
```bash
git add index.html
git commit -m "feat: add admin panel tab with user management view"
```

---

### Task 7: Run SQL Migration in Supabase

This task is performed in the **Supabase dashboard SQL editor**, not in code.

- [ ] **Step 1: Open Supabase SQL editor**

Go to your Supabase project → SQL Editor → New Query.

- [ ] **Step 2: Run the migration**

Paste and run:
```sql
-- Create profiles table
create table if not exists sr_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  email text not null,
  role text not null default 'user',
  created_at timestamptz default now()
);

-- Enable RLS on all tables
alter table betiq_parlays enable row level security;
alter table betiq_favorites enable row level security;
alter table betiq_bankroll enable row level security;
alter table sr_profiles enable row level security;

-- betiq_parlays: users see own rows; admin sees all
create policy "own_parlays" on betiq_parlays for all
  using (auth.uid()::text = user_id OR auth.email() = 'nikkimasani@gmail.com');

-- betiq_favorites: users see own rows; admin sees all
create policy "own_favorites" on betiq_favorites for all
  using (auth.uid()::text = user_id OR auth.email() = 'nikkimasani@gmail.com');

-- betiq_bankroll: users see own rows; admin sees all
create policy "own_bankroll" on betiq_bankroll for all
  using (auth.uid()::text = user_id OR auth.email() = 'nikkimasani@gmail.com');

-- sr_profiles: users see/update own; admin sees all
create policy "profiles_select" on sr_profiles for select
  using (auth.uid() = id OR auth.email() = 'nikkimasani@gmail.com');
create policy "profiles_insert" on sr_profiles for insert
  with check (auth.uid() = id);
create policy "profiles_update" on sr_profiles for update
  using (auth.uid() = id);
```

- [ ] **Step 3: Verify**

In Supabase → Table Editor, confirm `sr_profiles` table exists with columns: `id`, `display_name`, `email`, `role`, `created_at`.

Check Authentication → Settings: confirm "Enable email confirmations" is set per your preference (disable for easier testing, enable for production).

- [ ] **Step 4: Commit note**
```bash
git commit --allow-empty -m "chore: Supabase SQL migration applied (sr_profiles + RLS policies)"
```

---

## Spec Coverage

| Spec Requirement | Task |
|---|---|
| Rename BetIQ → SlateRun everywhere | Task 1 |
| Logo: `SLATE<span>RUN</span>` Barlow Condensed 800 | Task 1 |
| localStorage prefix `betiq_` → `sr_` | Task 1 |
| Hardcoded Supabase client + ADMIN_EMAIL constant | Task 2 |
| Remove user-configured Supabase Settings | Task 2 |
| Auth overlay: Split Panel B (red-orange left, form right) | Task 3 |
| Profile pill in header (avatar + first name) | Task 3 |
| Admin nav tab (hidden by default) | Task 3 |
| `initAuth()` session check on load | Task 4 |
| Sign-in / sign-up with error handling | Task 4 |
| `loadUser()` loads user-specific localStorage data | Task 4 |
| `onAuthStateChange` listener | Task 4 |
| Sign out from profile dropdown | Task 4 |
| `sbClient` → `sb`, `SB_USER` → `state.user.id` | Task 5 |
| Per-user localStorage keys with `_${userId}` suffix | Task 5 |
| `syncBankrollToSupabase()` wired to bankroll changes | Task 5 |
| Admin panel: user table + summary stats | Task 6 |
| Admin panel: read-only, email + name + bankroll + record | Task 6 |
| Admin only visible to `nikkimasani@gmail.com` | Task 6 |
| `sr_profiles` table with `email` column | Task 7 |
| RLS on all three `betiq_*` tables | Task 7 |
| Admin RLS policy (sees all rows) | Task 7 |
