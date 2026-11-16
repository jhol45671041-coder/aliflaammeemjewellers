import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const migration = readFileSync(new URL('../supabase/migrations/202610290001_stock_customers_posts.sql', import.meta.url), 'utf8');
const schema = readFileSync(new URL('../supabase/schema.sql', import.meta.url), 'utf8');

test('customer records and posts are protected by admin RLS', () => {
  for (const sql of [migration, schema]) {
    assert.match(sql, /alter table public\.customers enable row level security/);
    assert.match(sql, /alter table public\.posts enable row level security/);
    assert.match(sql, /create policy customers_admin_all on public\.customers[\s\S]*using \(public\.is_admin\(\)\) with check \(public\.is_admin\(\)\)/);
    assert.match(sql, /create policy posts_admin_all on public\.posts[\s\S]*using \(public\.is_admin\(\)\) with check \(public\.is_admin\(\)\)/);
  }
});

test('the public can read only published, due posts', () => {
  for (const sql of [migration, schema]) {
    assert.match(sql, /create policy posts_public_read on public\.posts[\s\S]*using \(status = 'published' and published_at <= now\(\)\)/);
  }
});

test('public piece grants exclude private inventory columns', () => {
  for (const sql of [migration, schema]) {
    assert.match(sql, /revoke select on public\.pieces from public, anon, authenticated/);
    const grant = sql.match(/grant select \(([^)]*)\)\s*on public\.pieces to anon, authenticated/);
    assert.ok(grant, 'column-level SELECT grant exists');
    for (const privateColumn of ['cost_price', 'sku', 'stock_quantity', 'low_stock_threshold', 'location', 'track_stock']) {
      assert.ok(!grant[1].includes(privateColumn), privateColumn + ' is not public');
    }
    assert.match(sql, /create or replace function public\.get_admin_pieces\(\)[\s\S]*security definer[\s\S]*where public\.is_admin\(\)/);
    assert.match(sql, /create or replace view public\.catalogue with \(security_invoker = true\)[\s\S]*from public\.pieces where visible/);
  }
});

test('full schema embeds the additive migration and has no placeholders', () => {
  const body = migration.split('begin;')[1].split('commit;')[0].trim();
  assert.ok(schema.includes(body), 'schema.sql contains the migration body');
  assert.ok(!schema.includes('placeholder'));
  assert.ok(!migration.includes('placeholder'));
});

const hardening = readFileSync(new URL('../supabase/migrations/202611060001_admin_and_booking_hardening.sql', import.meta.url), 'utf8');
const buildPy = readFileSync(new URL('../build.py', import.meta.url), 'utf8');

test('is_admin requires a confirmed account whose email is on the allow-list', () => {
  assert.match(hardening, /join auth\.users u on lower\(u\.email\) = lower\(a\.email\)/);
  assert.match(hardening, /u\.id = auth\.uid\(\)/);
  assert.match(hardening, /email_confirmed_at is not null/);
});

test('website bookings are validated and rate limited server-side', () => {
  assert.match(hardening, /grant insert \(name, phone, email, purpose, preferred_date, preferred_time, notes, source\)\s+on public\.appointments to anon/);
  assert.match(hardening, /revoke select, update, delete/);
  assert.match(hardening, /cf-connecting-ip/);
  assert.match(hardening, /Too many booking requests/);
  assert.match(hardening, /alter table public\.alm_appointment_rate enable row level security/);
});

test('every purpose on the booking form is accepted by the database', () => {
  const block = buildPy.match(/<select id="purpose"[\s\S]*?<\/select>/)[0];
  const labels = [...block.matchAll(/<option value="([^"]+)">([^<]+)<\/option>/g)]
    .map((m) => m[2].replace(/&amp;/g, '&'));
  assert.ok(labels.length >= 8);
  for (const label of labels) assert.ok(hardening.includes("'" + label + "'"), 'migration accepts purpose: ' + label);
  const times = [...buildPy.match(/<select id="time"[\s\S]*?<\/select>/)[0].matchAll(/<option value="(\d\d:\d\d)">/g)].map((m) => m[1]);
  for (const time of times) assert.ok(hardening.includes("'" + time + "'"), 'migration accepts time: ' + time);
});

const reviews = readFileSync(new URL('../supabase/migrations/202611090001_reviews.sql', import.meta.url), 'utf8');
const combined = readFileSync(new URL('../supabase/RUN_THIS_IN_SQL_EDITOR.sql', import.meta.url), 'utf8');

test('reviews: public can only submit unapproved reviews and read approved ones', () => {
  assert.match(reviews, /alter table public\.alm_reviews enable row level security/);
  assert.match(reviews, /for insert to anon, authenticated\s+with check \(approved = false\)/);
  assert.match(reviews, /create policy alm_reviews_public_read on public\.alm_reviews\s+for select to anon, authenticated\s+using \(approved = true\)/);
  for (const action of ['select', 'update', 'delete']) {
    assert.match(reviews, new RegExp('for ' + action + ' to authenticated\\s+using \\(public\\.is_admin\\(\\)\\)'), 'admin can ' + action);
  }
  assert.match(reviews, /new\.approved\s+:= false/);
  assert.match(reviews, /Too many reviews/);
  assert.doesNotMatch(reviews, /grant (all|update|delete)[^;]*to anon/);
});

test('the combined SQL editor file holds both unrun migrations in order', () => {
  const a = combined.indexOf(hardening.trim());
  const b = combined.indexOf(reviews.trim());
  assert.ok(a >= 0 && b > a, 'hardening first, then reviews');
});

test('the site carries no invented testimonials', () => {
  assert.doesNotMatch(buildPy, /TESTIMONIALS\s*=/);
  const home = readFileSync(new URL('../index.html', import.meta.url), 'utf8');
  assert.match(home, /id="reviewsList"/);
  assert.match(home, /Be the first to share your experience/);
  assert.match(home, /maps\.google\.com\/\?cid=9293768806817445409/);
});

test('admin email migration sets aliflaammeemjeweller@gmail.com as the sole owner', () => {
  const adminChange = readFileSync(new URL('../supabase/migrations/202611160001_change_admin_email.sql', import.meta.url), 'utf8');
  assert.match(adminChange, /insert into public\.admin_emails[\s\S]*'aliflaammeemjeweller@gmail\.com'/);
  assert.match(adminChange, /delete from public\.admin_emails\s+where lower\(email\) <> 'aliflaammeemjeweller@gmail\.com'/);
  assert.match(combined, /insert into public\.admin_emails[\s\S]*'aliflaammeemjeweller@gmail\.com'/);
  assert.match(combined, /delete from public\.admin_emails\s+where lower\(email\) <> 'aliflaammeemjeweller@gmail\.com'/);
});

test('all 37 build.py pieces and catalogue-photos storage are synced in SQL', () => {
  const syncSql = readFileSync(new URL('../supabase/migrations/202611160002_sync_catalogue_and_storage.sql', import.meta.url), 'utf8');
  const expectedIds = [...buildPy.matchAll(/dict\(id="([^"]+)"/g)].map((m) => m[1]);
  assert.equal(expectedIds.length, 37);
  for (const id of expectedIds) {
    assert.ok(schema.includes("'" + id + "'"), 'schema.sql seeds ' + id);
  }
  for (const id of expectedIds.slice(0, 15)) {
    assert.ok(syncSql.includes("'" + id + "'"), 'sync migration seeds ' + id);
  }
  for (const feat of ['meher', 'aab', 'zohra', 'sana', 'roshni', 'mahtab']) {
    assert.ok(syncSql.includes("'" + feat + "'"), 'sync migration preserves featured flag for ' + feat);
  }
  for (const sql of [syncSql, schema]) {
    assert.match(sql, /insert into storage\.buckets[\s\S]*'catalogue-photos'/);
    assert.match(sql, /create policy catalogue_photos_public_read on storage\.objects/);
    assert.match(sql, /create policy catalogue_photos_admin_insert on storage\.objects[\s\S]*public\.is_admin\(\)/);
    assert.match(sql, /create policy catalogue_photos_admin_update on storage\.objects[\s\S]*public\.is_admin\(\)/);
    assert.match(sql, /create policy catalogue_photos_admin_delete on storage\.objects[\s\S]*public\.is_admin\(\)/);
  }
  assert.ok(!buildPy.includes('static_only=True'), 'no product remains static-only without database management');
  const syncBody = syncSql.split('begin;')[1].split('commit;')[0].trim();
  assert.ok(combined.includes(syncBody), 'RUN_THIS_IN_SQL_EDITOR.sql includes sync_catalogue_and_storage');
});

