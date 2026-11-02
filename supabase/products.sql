-- Products table + photo storage for the Profile "Shelf" tab.
-- Run once in the Supabase SQL Editor.

create table if not exists public.products (
    id          uuid primary key default gen_random_uuid(),
    user_id     uuid not null references auth.users (id) on delete cascade,
    name        text not null,
    status      text not null default 'In rotation',
    image_url   text,
    created_at  timestamptz not null default now()
);

alter table public.products enable row level security;

create policy "Users can view own products"
    on public.products for select
    using (auth.uid() = user_id);

create policy "Users can add own products"
    on public.products for insert
    with check (auth.uid() = user_id);

create policy "Users can update own products"
    on public.products for update
    using (auth.uid() = user_id);

create policy "Users can delete own products"
    on public.products for delete
    using (auth.uid() = user_id);

-- Storage bucket for product photos (public so images load by URL).
-- Each user can only upload/delete files in a folder named after their user id.
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

create policy "Users can upload own product images"
    on storage.objects for insert to authenticated
    with check (bucket_id = 'product-images' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "Users can delete own product images"
    on storage.objects for delete to authenticated
    using (bucket_id = 'product-images' and (storage.foldername(name))[1] = auth.uid()::text);
