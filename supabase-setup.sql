create table if not exists public.artifacts (
  slug text primary key check (slug ~ '^[a-z0-9-]+$'),
  name text not null,
  province text not null,
  category text not null check (category in ('Artifact', 'Value')),
  subtitle text not null,
  description text not null,
  model_path text not null,
  audio_path text,
  archive_path text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.artifacts enable row level security;

drop policy if exists "Public can read artifacts" on public.artifacts;
create policy "Public can read artifacts"
  on public.artifacts
  for select
  to anon, authenticated
  using (true);

insert into public.artifacts
  (slug, name, province, category, subtitle, description, model_path, audio_path, archive_path)
values
  ('lagpi', 'Lagpi', 'Abra', 'Artifact', 'Traditional Container',
   'A traditional container used to carry crops, tools, and other supplies.',
   '3D ASSETS/abra-lagpi.glb', null, 'abra-archive.html'),
  ('tinali', 'Tinali', 'Abra', 'Artifact', 'Traditional Beaded Arm Ornaments',
   'Traditional beaded arm ornaments worn by women during formal occasions.',
   '3D ASSETS/abra-tinali.glb', null, 'abra-archive.html'),
  ('tungali', 'Tungali', 'Apayao', 'Artifact', 'Traditional Bamboo Flute',
   'A traditional bamboo flute used to produce music during cultural activities.',
   '3D ASSETS/apayao-tungali.glb', null, 'apayao-archive.html'),
  ('aliwa', 'Aliwa', 'Apayao', 'Artifact', 'Traditional Curved-Blade Tool',
   'A traditional curved-blade tool used for farming and other daily tasks.',
   '3D ASSETS/apayao-aliwa.glb', null, 'apayao-archive.html'),
  ('solibao', 'Solibao', 'Benguet', 'Artifact', 'Traditional Drum',
   'A traditional drum played during dances, ceremonies, and celebrations.',
   '3D ASSETS/benguet-solibao.glb', 'Audio Assets/solibao-sound.mp3', 'benguet-archive.html'),
  ('kayabang', 'Kayabang', 'Benguet', 'Artifact', 'Traditional Basket',
   'A traditional basket used to carry crops across mountain trails.',
   '3D ASSETS/benguet-kayabang.glb', null, 'benguet-archive.html'),
  ('atang', 'Atang', 'Benguet', 'Value', 'Traditional Food-Offering Ritual',
   'A traditional food-offering ritual associated with ancestral remembrance and spiritual appeasement.',
   '3D ASSETS VALUES/Benguet-Atang.glb', null, 'benguet-archive.html'),
  ('ginuttu', 'Ginuttu', 'Ifugao', 'Artifact', 'Traditional Shell Belt',
   'A traditional shell belt worn by elite Ifugao men during special occasions.',
   '3D ASSETS/ifugao-ginuttu.glb', null, 'ifugao-archive.html'),
  ('bulul', 'Bulul', 'Ifugao', 'Artifact', 'Traditional Sculpture',
   'A carved wooden figure associated with rice harvests and protection.',
   '3D ASSETS/ifugao-bulul.glb', null, 'ifugao-archive.html'),
  ('sinawit', 'Sinawit', 'Kalinga', 'Artifact', 'Traditional Head Axe',
   'A traditional head axe historically used by Cordilleran warriors.',
   '3D ASSETS/kalinga-sinawit.glb', null, 'kalinga-archive.html'),
  ('immoso', 'Immoso', 'Kalinga', 'Artifact', 'Traditional Ceramic Jars',
   'Handmade clay vessels used to store water and traditional beverages.',
   '3D ASSETS/kalinga-ceramic_jars.glb', null, 'kalinga-archive.html'),
  ('baoya', 'Baoya', 'Mountain Province', 'Artifact', 'Traditional Necklace',
   'A traditional necklace made from boar tusks or shell ornaments.',
   '3D ASSETS/mt.province-baoya.glb', null, 'mountain-province-archive.html'),
  ('kalasag', 'Kalasag', 'Mountain Province', 'Artifact', 'Traditional Shield',
   'A traditional wooden shield used for defense in combat.',
   '3D ASSETS/mt.province-kalasag.glb', null, 'mountain-province-archive.html')
on conflict (slug) do update set
  name = excluded.name,
  province = excluded.province,
  category = excluded.category,
  subtitle = excluded.subtitle,
  description = excluded.description,
  model_path = excluded.model_path,
  audio_path = excluded.audio_path,
  archive_path = excluded.archive_path,
  updated_at = now();
