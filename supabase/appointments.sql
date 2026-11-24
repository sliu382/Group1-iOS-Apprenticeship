-- Appointments table for the Calendar tab.
-- Run once in the Supabase SQL Editor, after profiles.sql.
-- This already includes the columns from appointments_add_schedule_fields.sql
-- and appointments_add_recurrence.sql, so those two are only needed for
-- databases created before they existed (running them again is harmless).

create table if not exists public.appointments (
    id                    uuid primary key default gen_random_uuid(),
    user_id               uuid not null references auth.users (id) on delete cascade,
    title                 text not null,
    date                  timestamptz not null,
    location              text,
    notes                 text,
    is_complete           boolean not null default false,
    created_at            timestamptz not null default now(),
    updated_at            timestamptz not null default now(),
    end_date              timestamptz,
    is_all_day            boolean not null default false,
    notify_minutes_before integer,
    recurrence            jsonb,   -- null = happens once
    constraint appointment_title_not_blank check (length(btrim(title)) > 0)
);

create index if not exists appointments_user_date_idx on public.appointments (user_id, date);

-- Row Level Security: users can only see and edit their own appointments.
alter table public.appointments enable row level security;

drop policy if exists "Users can view own appointments"   on public.appointments;
drop policy if exists "Users can insert own appointments" on public.appointments;
drop policy if exists "Users can update own appointments" on public.appointments;
drop policy if exists "Users can delete own appointments" on public.appointments;

create policy "Users can view own appointments"
    on public.appointments for select to authenticated
    using ((select auth.uid()) = user_id);

create policy "Users can insert own appointments"
    on public.appointments for insert to authenticated
    with check ((select auth.uid()) = user_id);

create policy "Users can update own appointments"
    on public.appointments for update to authenticated
    using ((select auth.uid()) = user_id)
    with check ((select auth.uid()) = user_id);

create policy "Users can delete own appointments"
    on public.appointments for delete to authenticated
    using ((select auth.uid()) = user_id);
