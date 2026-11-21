-- Discover feed: community posts, likes, saves, and comments.
-- Run once in the Supabase SQL Editor.

-- @handle shown on posts (e.g. @softlysofia). Set in Profile -> Edit.
alter table public.profiles add column if not exists username text unique;

-- A post shares either one of the author's routines or a product recommendation.
create table if not exists public.posts (
    id            uuid primary key default gen_random_uuid(),
    user_id       uuid not null references auth.users (id) on delete cascade,
    category      text not null check (category in ('skincare', 'hair', 'makeup')),
    kind          text not null check (kind in ('routine', 'recommendation')),
    title         text not null,
    body          text,
    routine_id    uuid references public.routines (id) on delete set null,
    product_name  text,
    product_price text,
    created_at    timestamptz not null default now()
);

create table if not exists public.post_likes (
    post_id    uuid not null references public.posts (id) on delete cascade,
    user_id    uuid not null references auth.users (id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (post_id, user_id)
);

create table if not exists public.post_saves (
    post_id    uuid not null references public.posts (id) on delete cascade,
    user_id    uuid not null references auth.users (id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (post_id, user_id)
);

create table if not exists public.post_comments (
    id         uuid primary key default gen_random_uuid(),
    post_id    uuid not null references public.posts (id) on delete cascade,
    user_id    uuid not null references auth.users (id) on delete cascade,
    body       text not null,
    created_at timestamptz not null default now()
);

-- Row Level Security: any signed-in user can read posts, likes and comments;
-- people can only create/delete their own. Saves are private.
alter table public.posts         enable row level security;
alter table public.post_likes    enable row level security;
alter table public.post_saves    enable row level security;
alter table public.post_comments enable row level security;

create policy "Signed-in users can read posts"   on public.posts for select to authenticated using (true);
create policy "Users can create own posts"       on public.posts for insert to authenticated with check (auth.uid() = user_id);
create policy "Users can delete own posts"       on public.posts for delete to authenticated using (auth.uid() = user_id);

create policy "Signed-in users can read likes"   on public.post_likes for select to authenticated using (true);
create policy "Users can like"                   on public.post_likes for insert to authenticated with check (auth.uid() = user_id);
create policy "Users can unlike"                 on public.post_likes for delete to authenticated using (auth.uid() = user_id);

create policy "Users can read own saves"         on public.post_saves for select to authenticated using (auth.uid() = user_id);
create policy "Users can save"                   on public.post_saves for insert to authenticated with check (auth.uid() = user_id);
create policy "Users can unsave"                 on public.post_saves for delete to authenticated using (auth.uid() = user_id);

create policy "Signed-in users can read comments" on public.post_comments for select to authenticated using (true);
create policy "Users can comment"                 on public.post_comments for insert to authenticated with check (auth.uid() = user_id);
create policy "Users can delete own comments"     on public.post_comments for delete to authenticated using (auth.uid() = user_id);

-- Feed view: each post with its author's public name/handle, counts, the viewer's
-- like/save state, and the shared routine's step titles. Only these columns are
-- exposed, so the rest of each profile (skin type etc.) stays private.
create or replace view public.feed_posts as
select
    p.id, p.user_id, p.category, p.kind, p.title, p.body, p.routine_id,
    p.product_name, p.product_price, p.created_at,
    coalesce(nullif(trim(concat_ws(' ', pr.first_name, pr.last_name)), ''), 'Muse member') as author_name,
    coalesce(pr.username, lower(regexp_replace(coalesce(pr.first_name, 'member'), '\s', '', 'g'))) as author_username,
    (select count(*) from public.post_likes l where l.post_id = p.id)::int as like_count,
    (select count(*) from public.post_comments c where c.post_id = p.id)::int as comment_count,
    exists (select 1 from public.post_likes l where l.post_id = p.id and l.user_id = auth.uid()) as liked_by_me,
    exists (select 1 from public.post_saves s where s.post_id = p.id and s.user_id = auth.uid()) as saved_by_me,
    coalesce((select json_agg(rs.title order by rs.step_order)
              from public.routine_steps rs where rs.routine_id = p.routine_id), '[]'::json) as step_titles
from public.posts p
left join public.profiles pr on pr.id = p.user_id;

create or replace view public.feed_comments as
select
    c.id, c.post_id, c.user_id, c.body, c.created_at,
    coalesce(nullif(trim(concat_ws(' ', pr.first_name, pr.last_name)), ''), 'Muse member') as author_name,
    coalesce(pr.username, lower(regexp_replace(coalesce(pr.first_name, 'member'), '\s', '', 'g'))) as author_username
from public.post_comments c
left join public.profiles pr on pr.id = c.user_id;

-- Only signed-in users can read the views.
revoke all on public.feed_posts, public.feed_comments from anon, public;
grant select on public.feed_posts, public.feed_comments to authenticated;
