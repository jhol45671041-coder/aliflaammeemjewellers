-- Sync the 15 static_only new-arrival pieces from build.py into public.pieces
-- and configure the public catalogue-photos Storage bucket with admin-only writes.
-- Project: wqxodgwgmbmssalapcjz (alif-laam-meem-jewellers)
-- Safe to re-run (idempotent). Does not overwrite admin edits on existing pieces
-- and leaves the private alm-product-photos-v1 bucket untouched.
begin;

-- 1. First-run ordering alignment: if the 15 new arrivals have not been seeded yet,
--    shift the original 22 pieces (sort_order 0..21) to 15..36 and restore the
--    featured flags defined in build.py (schema.sql originally omitted featured).
do $$
begin
  if not exists (select 1 from public.pieces where id = 'yaqoot') then
    update public.pieces
    set sort_order = sort_order + 15
    where id in (
      'meher', 'aab', 'zohra', 'sana', 'noor', 'roshni', 'hina', 'gulbahar',
      'mahtab', 'vasl', 'dilruba', 'zoya', 'reyaz', 'mahnoor', 'areeba',
      'dildar', 'suhani', 'zar', 'sitara', 'sahr', 'nazm', 'maahru'
    )
      and sort_order between 0 and 21;

    update public.pieces
    set featured = true
    where id in ('meher', 'aab', 'zohra', 'sana', 'roshni', 'mahtab')
      and featured = false;
  end if;
end $$;

-- 2. Seed all 15 new-arrival pieces so the Admin Panel and public website share
--    the exact same database source of truth.
insert into public.pieces
  (id, name, type, occasion, motif, badge,
   metals, tags,
   description, story,
   specs, photo, sort_order, visible, featured)
values
  ('yaqoot', 'Yaqoot Ruby Halo Ring', 'rings', 'engagement', 'rings', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'An oval ruby-red stone ringed by a halo of white stones on a slim 21K gold band.', 'A deep oval ruby-red centre stone framed by a crown of small white stones, set on a slim polished 21K gold band. Classic enough for an engagement, bright enough for every day.',
   '[["Metal", "21K yellow gold"], ["Stones", "Oval ruby-red centre, white stone halo"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/yaqoot.webp', 0, true, false),
  ('shahana', 'Shahana Bridal Necklace Set', 'bridal', 'bridal', 'bridal', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'A sculpted 21K gold necklace with ruby-red and emerald-green bead fringes and matching earrings.', 'A broad hand-worked 21K gold collar with a central green stone and pendant drop, finished with fringes of ruby-red and emerald-green beads, and paired with long matching earrings strung on red and green beaded sahare.',
   '[["Metal", "21K yellow gold"], ["Set", "Necklace and earrings"], ["Detail", "Red and green bead fringes"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/shahana.webp', 1, true, false),
  ('nargis', 'Nargis Flower Drop Earrings', 'earrings', 'everyday', 'earrings', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'Flower tops set with small red stones, with polished gold drops below.', 'Petal-shaped 21K gold tops with small red stones at their hearts, each finished with a polished gold drop that moves as the wearer turns. Light enough to wear all day.',
   '[["Metal", "21K yellow gold"], ["Stones", "Small red stones"], ["Style", "Flower top with drop"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/nargis.webp', 2, true, false),
  ('jharoka', 'Jharoka Filigree Ring', 'rings', 'festive', 'rings', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'A lattice-work 21K gold ring with a white rhodium accent, like a carved window screen.', 'Named for the carved window screens of old Lahore: an openwork 21K gold top in fine filigree and faceted cut-work, with a white rhodium V at its centre and a textured shank.',
   '[["Metal", "21K yellow gold"], ["Craft", "Filigree and cut-work"], ["Accent", "White rhodium detail"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/jharoka.webp', 3, true, false),
  ('neelam', 'Neelam Pearl Dome Ring', 'rings', 'festive', 'rings', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'A domed 21K gold ring with a pearl-like centre ringed by blue and white stones.', 'A raised 21K gold dome with a pearl-like centre, ringed by deep blue and small white stones in gold filigree. Blue and gold, the house pairing, in a piece made for festive evenings.',
   '[["Metal", "21K yellow gold"], ["Stones", "Pearl-like centre, blue and white stones"], ["Style", "Domed cocktail ring"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/neelam.webp', 4, true, false),
  ('shamsa', 'Shamsa Lattice Ring', 'rings', 'festive', 'rings', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'A geometric 21K gold cocktail ring set with rows of smoky brown stones.', 'A bold geometric face in 21K gold, set in neat rows of small smoky brown stones so the whole top glints like a lattice of light.',
   '[["Metal", "21K yellow gold"], ["Stones", "Smoky brown stones"], ["Style", "Geometric cocktail ring"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/shamsa.webp', 5, true, false),
  ('sabah', 'Sabah Zircon Necklace Set', 'necklace', 'festive', 'necklace', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'A sweeping leaf-motif necklace in gold and white zircon, with matching long drop earrings.', 'A modern 21K gold necklace that sweeps into a swirling leaf pendant lined with sparkling white zircon, paired with long matching drop earrings. Made for weddings, dinners and every festive table in between.',
   '[["Metal", "21K yellow gold"], ["Stones", "White zircon"], ["Set", "Necklace and earrings"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/sabah.webp', 6, true, false),
  ('wafa', 'Wafa Promise Ring', 'rings', 'gifting', 'rings', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'A slim 21K gold band with a delicate hand motif holding a single white stone.', 'A fine 21K gold band whose top curls into a small hand holding a single white stone: a quiet promise, sized for every day and made for gifting.',
   '[["Metal", "21K yellow gold"], ["Stone", "Single white stone"], ["Style", "Slim band"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/wafa.webp', 7, true, false),
  ('bela', 'Bela Filigree Jhumki Earrings', 'earrings', 'festive', 'earrings', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'Domed filigree tops with white rhodium leaves and small gold cage drops.', 'Rounded 21K gold tops worked in leaf-pattern filigree with white rhodium accents, each finished with a small gold cage drop that sways with every movement.',
   '[["Metal", "21K yellow gold"], ["Craft", "Filigree with rhodium accents"], ["Drops", "Gold cage jhumki"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/bela.webp', 8, true, false),
  ('champa', 'Champa Jhumka Earrings', 'earrings', 'festive', 'earrings', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'Flower tops with tiny red stones and small gold jhumka bells.', 'Named for the champa flower: petal tops in 21K gold with tiny red stones, each carrying a small gold jhumka bell beneath.',
   '[["Metal", "21K yellow gold"], ["Stones", "Small red stones"], ["Style", "Flower top with jhumka"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/champa.webp', 9, true, false),
  ('kiran', 'Kiran Charm Hoop Earrings', 'earrings', 'everyday', 'earrings', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'Slim 21K gold bali hoops finished with a small flower-and-drop charm.', 'Slim everyday bali hoops in 21K gold, each finished with a small flower charm and drop at its base. Easy to wear from morning to evening.',
   '[["Metal", "21K yellow gold"], ["Style", "Bali hoops with charm"], ["Wear", "Everyday"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/kiran.webp', 10, true, false),
  ('shehzadi', 'Shehzadi Rani Haar Bridal Set', 'bridal', 'bridal', 'bridal', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'A full bridal suite: gold choker, red and green beaded rani haar, earrings and maang tikka.', 'A complete bridal suite in 21K gold: a wide choker with red and green stones, a long rani haar of ruby-red and emerald-green bead strands with a large gold pendant, matching earrings and a maang tikka with a red drop.',
   '[["Metal", "21K yellow gold"], ["Set", "Choker, rani haar, earrings, maang tikka"], ["Detail", "Red and green bead strands"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/shehzadi.webp', 11, true, false),
  ('kehkashan', 'Kehkashan Two-Tone Ring', 'rings', 'festive', 'rings', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'An elongated 21K gold statement ring with matte and polished panels and white rhodium tips.', 'A long marquise-shaped face that runs the length of the finger, with matte and high-polish 21K gold panels and white rhodium leaves at either end.',
   '[["Metal", "21K yellow gold"], ["Finish", "Matte and polished, rhodium tips"], ["Style", "Statement ring"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/kehkashan.webp', 12, true, false),
  ('gulnar', 'Gulnar Filigree Ring', 'rings', 'festive', 'rings', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'A shield-shaped filigree ring with a flower centre and white rhodium petals.', 'A shield-shaped 21K gold face built around an open flower, with white rhodium petals top and bottom and small enamel accents in the filigree.',
   '[["Metal", "21K yellow gold"], ["Craft", "Filigree with rhodium petals"], ["Style", "Statement ring"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/gulnar.webp', 13, true, false),
  ('afreen', 'Afreen Petal Ring', 'rings', 'festive', 'rings', 'New arrival',
   ARRAY['gold21']::text[], ARRAY['New arrival', 'In stock']::text[],
   'A rounded 21K gold ring of curling filigree petals with small rhodium accents.', 'A rounded crown of curling filigree petals in 21K gold, lifted with small white rhodium accents, on a textured band.',
   '[["Metal", "21K yellow gold"], ["Craft", "Filigree petals"], ["Style", "Cocktail ring"], ["Availability", "In stock at the showroom"], ["Price", "On request"]]'::jsonb,
   'assets/products/afreen.webp', 14, true, false)
on conflict (id) do nothing;

-- 3. Public product photography bucket (admin-managed uploads).
--    Preserves alm-product-photos-v1 (private bucket for alm-commit-books-v1).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'catalogue-photos',
  'catalogue-photos',
  true,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/avif']::text[]
)
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists catalogue_photos_public_read on storage.objects;
create policy catalogue_photos_public_read on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'catalogue-photos');

drop policy if exists catalogue_photos_admin_insert on storage.objects;
create policy catalogue_photos_admin_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'catalogue-photos' and public.is_admin());

drop policy if exists catalogue_photos_admin_update on storage.objects;
create policy catalogue_photos_admin_update on storage.objects
  for update to authenticated
  using (bucket_id = 'catalogue-photos' and public.is_admin())
  with check (bucket_id = 'catalogue-photos' and public.is_admin());

drop policy if exists catalogue_photos_admin_delete on storage.objects;
create policy catalogue_photos_admin_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'catalogue-photos' and public.is_admin());

notify pgrst, 'reload schema';
commit;
