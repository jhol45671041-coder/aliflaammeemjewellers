-- Admin allow-list — update owner account (2026-11-16)
-- Project: wqxodgwgmbmssalapcjz (alif-laam-meem-jewellers)
-- Paste into: Supabase Dashboard -> project wqxodgwgmbmssalapcjz -> SQL Editor -> New query -> Run.
--
-- Replaces the previous owner address (d45671041@gmail.com) with
-- aliflaammeemjeweller@gmail.com. Safe to re-run.
-- Every policy in the database asks public.is_admin(), which reads this table,
-- and is_admin() additionally requires the signed-in account to have a
-- confirmed email — so sign in once and confirm the address before the panel
-- unlocks.
begin;

insert into public.admin_emails (email, note)
values ('aliflaammeemjeweller@gmail.com', 'Owner admin account')
on conflict (email) do update set note = excluded.note;

delete from public.admin_emails
where lower(email) <> 'aliflaammeemjeweller@gmail.com';

commit;

-- Check the result:
--   select email, note, created_at from public.admin_emails;
