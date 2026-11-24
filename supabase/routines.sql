-- Routines table: each user's named routines (e.g. "Morning skincare").
-- Run once in the Supabase SQL Editor, after profiles.sql.

create table if not exists public.routines (
    id          uuid primary key default gen_random_uuid(),
    user_id     uuid not null references auth.users (id) on delete cascade,
    name        text not null,
    created_at  timestamptz default now()
);

create index if not exists routines_user_id_idx on public.routines (user_id);

-- Row Level Security: users can only see and edit their own routines.
alter table public.routines enable row level security;

drop policy if exists "Read own routines"   on public.routines;
drop policy if exists "Create own routines" on public.routines;
drop policy if exists "Update own routines" on public.routines;
drop policy if exists "Delete own routines" on public.routines;

create policy "Read own routines"
    on public.routines for select to authenticated
    using ((select auth.uid()) = user_id);

create policy "Create own routines"
    on public.routines for insert to authenticated
    with check ((select auth.uid()) = user_id);

create policy "Update own routines"
    on public.routines for update to authenticated
    using ((select auth.uid()) = user_id)
    with check ((select auth.uid()) = user_id);

create policy "Delete own routines"
    on public.routines for delete to authenticated
    using ((select auth.uid()) = user_id);
