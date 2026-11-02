-- Adds the "Your beauty profile" fields to the profiles table.
-- Run once in the Supabase SQL Editor, after profiles.sql.

alter table public.profiles
    add column if not exists skin_type    text,
    add column if not exists hair_type    text,
    add column if not exists top_concern  text,
    add column if not exists beauty_style text;
