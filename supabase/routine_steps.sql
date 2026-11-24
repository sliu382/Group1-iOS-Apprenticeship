-- Routine steps: the ordered steps inside a routine.
-- Run once in the Supabase SQL Editor, after routines.sql.

create table if not exists public.routine_steps (
    id          uuid primary key default gen_random_uuid(),
    routine_id  uuid not null references public.routines (id) on delete cascade,
    title       text not null,
    item_name   text,
    description text,
    step_order  integer not null default 0,
    created_at  timestamptz default now()
);

create index if not exists routine_steps_routine_id_idx on public.routine_steps (routine_id);

-- Row Level Security: steps have no user_id, so ownership is checked
-- through the parent routine.
alter table public.routine_steps enable row level security;

drop policy if exists "Read own steps"   on public.routine_steps;
drop policy if exists "Create own steps" on public.routine_steps;
drop policy if exists "Update own steps" on public.routine_steps;
drop policy if exists "Delete own steps" on public.routine_steps;

create policy "Read own steps"
    on public.routine_steps for select to authenticated
    using (exists (
        select 1 from public.routines r
        where r.id = routine_steps.routine_id and r.user_id = (select auth.uid())
    ));

create policy "Create own steps"
    on public.routine_steps for insert to authenticated
    with check (exists (
        select 1 from public.routines r
        where r.id = routine_steps.routine_id and r.user_id = (select auth.uid())
    ));

create policy "Update own steps"
    on public.routine_steps for update to authenticated
    using (exists (
        select 1 from public.routines r
        where r.id = routine_steps.routine_id and r.user_id = (select auth.uid())
    ))
    with check (exists (
        select 1 from public.routines r
        where r.id = routine_steps.routine_id and r.user_id = (select auth.uid())
    ));

create policy "Delete own steps"
    on public.routine_steps for delete to authenticated
    using (exists (
        select 1 from public.routines r
        where r.id = routine_steps.routine_id and r.user_id = (select auth.uid())
    ));
