-- Lets appointments repeat. Stores the repeat rule as JSON, e.g.
-- {"frequency":"weekly","weekdays":[3,5],"until":"2026-12-31T05:00:00Z"}
-- null = happens once. Run once in the Supabase SQL editor.

alter table public.appointments
    add column if not exists recurrence jsonb;
