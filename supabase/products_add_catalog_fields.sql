-- Adds brand + barcode to shelf products so items picked from the
-- Open Beauty Facts catalog keep that info. Run once in the SQL Editor, after products.sql.

alter table public.products
    add column if not exists brand   text,
    add column if not exists barcode text;
