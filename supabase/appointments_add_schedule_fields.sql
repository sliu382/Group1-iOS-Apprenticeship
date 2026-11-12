-- Adds all-day, end time and notification fields to appointments.
-- Run this once in the Supabase SQL editor before using the new app build.
-- Existing rows keep working: new columns are nullable or have defaults.

alter table public.appointments
    add column if not exists end_date timestamptz,
    add column if not exists is_all_day boolean not null default false,
    add column if not exists notify_minutes_before integer;
