-- Saves the catalog brand, barcode and photo on product recommendation posts,
-- so people can add the product to their own shelf from the post.
-- Run once in the Supabase SQL Editor, after discover_posts.sql.

alter table public.posts
    add column if not exists product_brand     text,
    add column if not exists product_barcode   text,
    add column if not exists product_image_url text;

-- Same feed view as before, with the three new columns added at the end.
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
              from public.routine_steps rs where rs.routine_id = p.routine_id), '[]'::json) as step_titles,
    p.product_brand, p.product_barcode, p.product_image_url
from public.posts p
left join public.profiles pr on pr.id = p.user_id;
