-- SlateRun — Supabase migration
-- Run this in the Supabase SQL editor (project: bazjlrualnmbanmhiuau)

-- ─── PROFILES ────────────────────────────────────────────────────────────────
-- Auto-populated from auth.users on sign-up via trigger.

create table if not exists public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  email text,
  display_name text,
  created_at timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Authenticated users can read profiles"
  on public.profiles for select
  using (auth.role() = 'authenticated');

-- Trigger: create a profile row whenever a new user signs up
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, email, display_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ─── PARLAYS ─────────────────────────────────────────────────────────────────
create table if not exists public.betiq_parlays (
  id text primary key,
  user_id text not null,
  date text,
  legs jsonb,
  stake numeric,
  odds integer,
  payout text,
  result text default 'pending'
);

alter table public.betiq_parlays enable row level security;

create policy "Users manage own parlays"
  on public.betiq_parlays for all
  using (user_id = auth.uid()::text)
  with check (user_id = auth.uid()::text);

-- ─── FAVORITES ───────────────────────────────────────────────────────────────
create table if not exists public.betiq_favorites (
  id text primary key,
  user_id text not null,
  sport text,
  name text,
  sub text
);

alter table public.betiq_favorites enable row level security;

create policy "Users manage own favorites"
  on public.betiq_favorites for all
  using (user_id = auth.uid()::text)
  with check (user_id = auth.uid()::text);

-- ─── BANKROLL ────────────────────────────────────────────────────────────────
create table if not exists public.betiq_bankroll (
  user_id text primary key,
  balance numeric default 1000
);

alter table public.betiq_bankroll enable row level security;

create policy "Users manage own bankroll"
  on public.betiq_bankroll for all
  using (user_id = auth.uid()::text)
  with check (user_id = auth.uid()::text);
