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
  details jsonb not null default '[]'::jsonb,
  hotspots jsonb not null default '[]'::jsonb,
  animation_name text,
  autoplay boolean not null default false,
  loop boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.artifacts
  add column if not exists details jsonb not null default '[]'::jsonb;
alter table public.artifacts
  add column if not exists hotspots jsonb not null default '[]'::jsonb;
alter table public.artifacts
  add column if not exists animation_name text;
alter table public.artifacts
  add column if not exists autoplay boolean not null default false;
alter table public.artifacts
  add column if not exists loop boolean not null default false;
alter table public.artifacts
  drop constraint if exists artifacts_details_is_array;
alter table public.artifacts
  add constraint artifacts_details_is_array check (jsonb_typeof(details) = 'array');
alter table public.artifacts
  drop constraint if exists artifacts_hotspots_is_array;
alter table public.artifacts
  add constraint artifacts_hotspots_is_array check (jsonb_typeof(hotspots) = 'array');

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

update public.artifacts set
  details = $json$[
    {"heading":"Purpose","text":"Used by the Tinguian (Itneg) people to carry seeds, harvested crops, tools, and other supplies across rugged mountain trails. Its sturdy structure helps protect the contents during transport."},
    {"heading":"Materials Used","text":"Traditionally made from processed forest materials, with a rigid, box-like shape and a fitted lid or top flap. Rattan forms the main structure, while woven nito vines or split bamboo reinforce the edges and joints. It may also include woven shoulder straps for carrying."},
    {"heading":"References","text":"Lahot (A)| Bags and Carrying Accessories | Basketry | Bahay Ugnayanx. (n.d.). Bahay Ugnayan Research Center. https://www.bahayugnayan.org/bagsandaccessories/lahot-(a)"}
  ]$json$::jsonb,
  hotspots = $json$[
    {"position":"-0.1 0.85 0","normal":"0 1 0","label":"Carrying Straps","description":"The carrying straps are traditionally made from woven rattan or split bamboo. They allow the container to be carried more conveniently while keeping the user's hands free."},
    {"position":"-0.45 0.45 0.35","normal":"0 0 1","label":"Fitted Lid","description":"The Lagpi features a fitted lid or top flap that helps keep stored items secure and protected while traveling through rugged mountain trails."},
    {"position":"0 -0.4 0.35","normal":"0 1 0","label":"Woven Rattan Body","description":"The Lagpi is traditionally crafted from rattan using tightly woven patterns. Its sturdy, box-like structure provides strength and durability for carrying seeds, harvested crops, tools, and other supplies."}
  ]$json$::jsonb,
  updated_at = now()
where slug = 'lagpi';

update public.artifacts set
  details = $json$[
    {"heading":"Aesthetic Purpose","text":"Traditionally worn by women in pairs as tightly wrapped, layered armbands extending from the wrists to the forearms and sometimes reaching the upper arms. They are commonly worn during formal and ceremonial occasions."},
    {"heading":"Materials Used","text":"Made from hundreds of colorful antique glass seed beads (batek) arranged into intricate patterns of red, yellow, orange, white, black, and blue. The beads are individually tied by hand and secured with threads, cloth sleeves, or small buttons."},
    {"heading":"References","text":"Tinali (A) | Wearable Accessories | Beadworks | Bahay Ugnayan. (n.d.). Bahay Ugnayan Research Center. https://www.bahayugnayan.org/wearable-accessories/tinali-(a,b,c,d)"}
  ]$json$::jsonb,
  hotspots = $json$[
    {"position":"0.05 -0.045 0.3","normal":"0 1 0","label":"Colorful Glass Beads","description":"The Tinali is made from hundreds of colorful glass seed beads (batek), commonly featuring red, yellow, orange, white, black, and blue colors arranged into decorative patterns."},
    {"position":"-0.25 -0.045 0.88","normal":"0 0 1","label":"Intricate Beadwork Patterns","description":"The beads are carefully arranged into intricate geometric patterns, showcasing the craftsmanship and traditional decorative styles of Abra."},
    {"position":"-0.8 0.015 -0.2","normal":"0 1 0","label":"Threads and Fastenings","description":"The beads are individually secured using threads, cloth sleeves, or small buttons, helping hold the ornament together and allowing it to be wrapped around the arms."}
  ]$json$::jsonb,
  updated_at = now()
where slug = 'tinali';

update public.artifacts set
  details = $json$[
    {"heading":"Everyday and Combat Purpose","text":"Used for clearing thick vegetation, chopping firewood, and harvesting crops. Historically, it also served as a close-combat weapon, with its curved blade designed for effective swinging and striking."},
    {"heading":"Materials Used","text":"Features a forged steel blade with a broad, curved edge and a distinctive backward-pointing spur. Its handle is made from hardwood or carabao horn and reinforced with woven rattan (uway) for a secure grip."},
    {"heading":"References","text":"Aliwa (a). (n.d.). Bahay Ugnayan Research Center. https://www.bahayugnayan.org/community-group/isneg/aliwa-(a)"}
  ]$json$::jsonb,
  hotspots = $json$[
    {"position":"-0.2 0.75 0","normal":"0 1 0","label":"Curved Steel Blade","description":"The Aliwa features a forged steel blade with a broad, curved cutting edge designed for clearing vegetation, chopping firewood, and harvesting crops."},
    {"position":"0.25 0.85 0","normal":"0 1 0","label":"Backward-Pointing Spur","description":"The distinctive backward-pointing spur gives the Aliwa its recognizable shape and contributes to its functionality as a traditional cutting tool and close-combat weapon."},
    {"position":"0 -0.15 0","normal":"0 1 0","label":"Wooden Handle","description":"The handle is traditionally made from hardwood or carabao horn, sometimes reinforced with woven rattan (uway) to provide a secure and comfortable grip during use."}
  ]$json$::jsonb,
  updated_at = now()
where slug = 'aliwa';

update public.artifacts set
  details = $json$[
    {"heading":"Purpose","text":"A traditional bamboo musical instrument used to produce melodies during cultural activities and musical performances."},
    {"heading":"Materials Used","text":"Generally made from bamboo shaped into a narrow flute with openings that allow the player to produce different musical tones."},
    {"heading":"References","text":"Rica, & Rica. (2023, January 31). Amazing Philippine Indigenous bamboo musical instruments – Bamboo Music 101 - Bamboo Bootcamp. Bamboo Bootcamp -. https://bamboobootcamp.org/bamboo-musical-instruments/"}
  ]$json$::jsonb,
  hotspots = $json$[
    {"position":"-0.93 0.035 0","normal":"0 1 0","label":"Blowing End (Mouthpiece)","description":"The Tungali features a blowing end where the player directs air into the instrument to produce sound. The airflow creates vibrations inside the bamboo tube, generating musical tones."},
    {"position":"-0.5 0.035 0","normal":"0 0 1","label":"Finger Holes","description":"The finger holes allow the player to change musical notes by covering or uncovering them. Different finger positions produce different pitches and melodies."},
    {"position":"0.8 0.035 0","normal":"0 1 0","label":"Bamboo Body","description":"The Tungali is traditionally crafted from bamboo, a lightweight and naturally hollow material. Its tubular structure allows sound to resonate, producing the flute's distinctive musical tones."}
  ]$json$::jsonb,
  updated_at = now()
where slug = 'tungali';

update public.artifacts set
  details = $json$[
    {"heading":"Agricultural and Ritual Purpose","text":"Laid out on household altars, grave tombs, or outdoor clearings to honor the souls of the deceased (umalagad), remember relatives during Undas, or seek healing from illnesses caused by unseen spirits. It is also used in localized rituals led by family elders or traditional spiritual practitioners."},
    {"heading":"Ritual Elements and Offerings","text":"Composed mainly of local delicacies such as sticky rice cakes (suman or patopat), sliced boiled eggs, and pork. These food elements are paired with traditional items like native rice wine (tapuy), rolled tobacco leaves, or betel nut chews (mama), arranged on native woven trays or banana leaves."},
    {"heading":"References","text":"Cholinas, J. A. (2026). Change and continuity of cañao, atang, and hilot in Lower Dagsian, Baguio City. International Journal for Multidisciplinary Research, 8(5). https://doi.org/10.36948/ijfmr.2026.v08i05.88261"}
  ]$json$::jsonb,
  hotspots = $json$[
    {"position":"0.05 1.2 0.4","normal":"0 1 0","label":"Food Offerings","description":"The Atang consists of traditional food offerings such as sticky rice cakes, boiled eggs, and pork. These are prepared and presented to honor deceased relatives and ancestral spirits."},
    {"position":"0.25 1.1 0.88","normal":"0 0 1","label":"Offering Table (Altar)","description":"The table serves as a designated surface for arranging ritual offerings. Atang may be placed on household altars, graves, or other locations considered appropriate for ancestral remembrance."},
    {"position":"-0.2 1.6 0","normal":"0 1 0","label":"Ritual Practitioner","description":"The person represents someone preparing or presenting the Atang. These offerings are traditionally arranged by family members or elders as an expression of remembrance, respect, and connection with deceased loved ones."},
    {"position":"-0.5 1.1 0.94","normal":"0 1 0","label":"Image of the Deceased","description":"The image represents the deceased loved one being honored through the Atang ritual. It serves as a visual reminder of the person and symbolizes the family's remembrance, respect, and continuing connection with their departed relative."}
  ]$json$::jsonb,
  updated_at = now()
where slug = 'atang';

update public.artifacts set
  details = $json$[
    {"heading":"Agricultural and Ritual Purpose","text":"Placed inside rice granaries (alang) and homes to protect stored rice, encourage good harvests, and guard against pests or theft. It is also used in sacred rituals led by traditional priests (mumbaki)."},
    {"heading":"Materials Used","text":"Carved mainly from hardwoods such as narra, ipil, or tree fern (gulgul). The figures are shaped into simple human forms and may darken over time from smoke and ritual offerings."},
    {"heading":"References","text":"National Heritage Month – Benguet Provincial Library. (2024, May 9). https://bplibrary.benguetprovince.com/national-heritage-month-2/"}
  ]$json$::jsonb,
  hotspots = $json$[
    {"position":"0.55 0.85 0.7","normal":"0 1 0","label":"Wide Opening (Upper Rim)","description":"The wide opening allows farmers to easily place and remove harvested crops such as vegetables, root crops, and rice."},
    {"position":"-0.35 0.005 0.35","normal":"0 0 1","label":"Woven Body","description":"The tightly woven body provides strength and support for carrying agricultural produce. Its construction helps keep harvested crops securely inside the basket."},
    {"position":"0 -0.9 0.35","normal":"0 1 0","label":"Reinforced Base","description":"The narrower, reinforced base supports the basket's structure and helps it maintain its shape when carrying agricultural products."}
  ]$json$::jsonb,
  updated_at = now()
where slug = 'kayabang';

update public.artifacts set
  details = $json$[
    {"heading":"Cultural and Ritual Purpose","text":"Used by the Ibaloi and Kankanaey to provide rhythm for traditional dances such as the tayaw and bendiyan. It is also played during harvest celebrations, healing ceremonies, weddings, and other community gatherings."},
    {"heading":"Materials Used","text":"Traditionally made from a hollowed-out log or pipe shaped into a long, narrow drum body. An animal-skin drumhead, often made from deer or pig skin, is stretched over the wider opening and secured with rattan strips or strong lacings."},
    {"heading":"References","text":"Solibao- cultural music instrument — Steemit. (n.d.). Steemit. https://steemit.com/philippines/@ayahlicious/solibao-cultural-music-instrument"}
  ]$json$::jsonb,
  hotspots = $json$[
    {"position":"0.01 0.95 0.01","normal":"0 1 0","label":"Sound of Solibao*","description":"","audio":true},
    {"position":"0 0.70 0.045","normal":"0 0 1","label":"Strings","description":"Rattan (Wey): This is the most authentic and culturally accurate material used by Cordilleran artisans. Rattan is a naturally flexible, vine-like palm that becomes incredibly tough and rigid once dried, allowing it to hold tension over long periods without snapping under heavy drumming."},
    {"position":"-0.015 -0.50 0","normal":"0 -1 0.6","label":"Base","description":"Narra (Pterocarpus indicus): This is the top choice for master instrument makers. It is a dense, high-quality hardwood known for its exceptional durability and superior acoustic resonance."}
  ]$json$::jsonb,
  updated_at = now()
where slug = 'solibao';

update public.artifacts set
  details = $json$[
    {"heading":"Agricultural and Ritual Purpose","text":"Placed inside rice granaries (alang) and homes to protect stored rice, encourage good harvests, and guard against pests or theft. It is also used in sacred rituals led by traditional priests (mumbaki)."},
    {"heading":"Materials Used","text":"Carved mainly from hardwoods such as narra, ipil, or tree fern (gulgul). The figures are shaped into simple human forms and may darken over time from smoke and ritual offerings."},
    {"heading":"References","text":"National Museum of the Philippines. (2022, November 30). Bulul and the Socio-Cultural Significance of Rice – National Museum. https://www.nationalmuseum.gov.ph/2022/11/30/bulul-and-the-socio-cultural-significance-of-rice/"}
  ]$json$::jsonb,
  hotspots = $json$[
    {"position":"0 0.9 0.35","normal":"0 1 0","label":"Head and Facial Features","description":"The Bulul features simplified human facial characteristics, including prominent eyes, a defined nose, and carved ears, reflecting traditional Ifugao woodcarving styles."},
    {"position":"0.3 -0.045 0.4","normal":"0 0 1","label":"Squatting Position","description":"The Bulul is commonly depicted in a seated or squatting position, with its knees raised toward its chest. This posture is a recognizable feature of traditional Ifugao Bulul figures."},
    {"position":"0 0.015 -0.55","normal":"0 1 0","label":"Wooden Material","description":"Traditionally carved from wood such as narra, ipil, or tree fern, Bulul figures may develop darker surfaces over time due to smoke and ritual offerings."},
    {"position":"0 -0.85 0.65","normal":"0 1 0","label":"Carved Base","description":"The carved wooden base provides support and stability to the figure. In this example, it forms part of the sculpture and allows the Bulul to stand upright."}
  ]$json$::jsonb,
  updated_at = now()
where slug = 'bulul';

update public.artifacts set
  details = $json$[
    {"heading":"Purpose","text":"Traditionally worn by wealthy elite men known as kadangyan as a ceremonial belt and sword belt. It is displayed during important celebrations, marriage rituals, funeral rites, and ceremonies recognizing social rank."},
    {"heading":"Materials Used","text":"Made from hand-carved, disc-shaped shell pieces, often sourced from giant clams or mother-of-pearl. The discs are strung together using rattan, cotton thread, or bark thread and completed with a central shell or wooden buckle called an upod."},
    {"heading":"References","text":"Ginuttu| Personal Adornments | Ornaments | Bahay Ugnayan. (n.d.). Bahay Ugnayan Research Center. https://www.bahayugnayan.org/personal-adornments/ginuttu"}
  ]$json$::jsonb,
  hotspots = $json$[
    {"position":"0.05 -0.045 0.3","normal":"0 1 0","label":"Shell Discs","description":"The Ginuttu features hand-carved, disc-shaped shell pieces, often made from giant clam shells or mother-of-pearl. These are carefully shaped and polished to create the ornament's distinctive appearance."},
    {"position":"0.25 -0.045 0.88","normal":"0 0 1","label":"Red Binding Threads","description":"The shell discs are strung together using rattan, cotton thread, or bark thread. The cords hold the pieces together and allow the ornament to be worn as a ceremonial belt."},
    {"position":"-0.4 0.015 -0.2","normal":"0 1 0","label":"Ceremonial Bolo","description":"The bolo is a traditional bladed tool that accompanies the Ginuttu as part of ceremonial attire. It serves as a symbol of status and prestige when worn by high-ranking Ifugao men during important occasions."},
    {"position":"0.3 0.015 -0.65","normal":"0 1 0","label":"Central Buckle (Upod)","description":"The Upod serves as the central buckle of the Ginuttu. Traditionally made from shell or wood, it secures the belt and forms a prominent decorative feature of the ornament."},
    {"position":"-0.6 0 0.1","normal":"0 1 0","label":"Wooden Sheathe","description":"The sheath is crafted from carved wood and designed to hold and protect the bolo's blade. It also allows the weapon to be securely carried as part of traditional ceremonial attire."}
  ]$json$::jsonb,
  updated_at = now()
where slug = 'ginuttu';

update public.artifacts set
  details = $json$[
    {"heading":"Everyday Purpose","text":"Used for collecting and storing water, fermenting and aging traditional rice or sugarcane wine (basi), and serving beverages during household and community gatherings."},
    {"heading":"Materials Used","text":"Made from local earthenware clay using hand-modeling, coiling, and paddle-and-anvil techniques. The jars are polished with a smooth stone, decorated with geometric patterns, pit-fired, and coated with tree resin (dikay) for durability and water resistance."},
    {"heading":"References","text":"“6. Pottery Production and Distribution among the Kalinga: A Study of Household and Regional Organization and Differentiation” in “Ceramic Ethnoarchaeology” | University of Arizona Press. (n.d.). https://open.uapress.arizona.edu/read/fa6d6205-83f1-4ab0-b810-4a5f203c37af/section/f060a7bc-df63-4bc7-9cec-1348372ca1a9"}
  ]$json$::jsonb,
  hotspots = $json$[
    {"position":"0.05 0.9 0.4","normal":"0 1 0","label":"Wide Opening and Rim","description":"The Immoso features a wide circular opening with a thickened rim, allowing liquids to be easily poured in and out of the vessel."},
    {"position":"0.25 -0.045 0.58","normal":"0 0 1","label":"Clay Body","description":"The vessel is traditionally handcrafted from local earthenware clay using techniques such as coiling and hand-modeling. Its rounded body provides space for storing water and traditional beverages."},
    {"position":"-0.58 0.4 0","normal":"0 1 0","label":"Decorative Bands and Side Attachments","description":"The raised bands add texture to the vessel's surface, while the side attachments may help secure cords for handling or transporting the jar."}
  ]$json$::jsonb,
  updated_at = now()
where slug = 'immoso';

update public.artifacts set
  details = $json$[
    {"heading":"Purpose","text":"A traditional head axe historically associated with Cordilleran warriors. It was used as a weapon and is connected to traditional warrior practices and historical conflicts."},
    {"heading":"Materials Used","text":"Features a curved blade made from forged steel or iron, sometimes using recycled metal. The blade has a distinctive rear spike and is attached to a hardwood handle, with metal bands reinforcing the connection."},
    {"heading":"References","text":"Head Axe Sinawit - IFICAH Virtueller Rundgang. (2021, March 10). IFICAH Virtueller Rundgang. https://ificah-vr.de/exhibition-you-can-leave-your-head-on/philippines/philippines-room-view-1/head-axe-sinawit/?lang=en"}
  ]$json$::jsonb,
  hotspots = $json$[
    {"position":"-0.2 0.75 0","normal":"0 1 0","label":"Curved Steel Blade","description":"The Sinawit features a curved blade made from forged steel or iron. Its wide cutting edge was designed for striking and was traditionally used as a weapon by Cordilleran warriors."},
    {"position":"0.35 0.9 0","normal":"0 1 0","label":"Rear Spike","description":"The distinctive rear spike gives the Sinawit its recognizable shape and provides an additional pointed striking feature during combat."},
    {"position":"0.1 -0.15 0","normal":"0 1 0","label":"Wooden Handle","description":"The handle is traditionally crafted from hardwood, providing a firm grip and control when swinging the axe. Metal bands may reinforce the connection between the blade and handle, improving its durability."}
  ]$json$::jsonb,
  updated_at = now()
where slug = 'sinawit';

update public.artifacts set
  details = $json$[
    {"heading":"Purpose","text":"Traditionally worn by elite Bontok men, warriors, and priests during major celebrations, traditional dances, and agricultural ceremonies such as the begnas. It is also associated with historical warrior traditions and may be passed down as a family heirloom."},
    {"heading":"Materials Used","text":"Made from wild boar tusks or polished mother-of-pearl shaped like teeth. These pieces are arranged and secured to a sturdy woven band made from rattan and runo reeds."},
    {"heading":"References","text":"Necklace (Boaya) | Mapping Philippine Material Culture. (n.d.). Mapping Philippine Material Culture. https://philippinestudies.uk/mapping/items/show/15355"}
  ]$json$::jsonb,
  hotspots = $json$[
    {"position":"0.85 -0.045 -0.7","normal":"0 1 0","label":"Curved Boar Tusks","description":"The Baoya features curved wild boar tusks that give the necklace its distinctive appearance. These ornaments are associated with traditional warrior attire and social prestige."},
    {"position":"0.25 -0.045 0.68","normal":"0 0 1","label":"Tusk and Shell Pendants","description":"The necklace features pointed pendants made from animal tusks or polished shell materials. These are arranged along the necklace to create a decorative and symmetrical appearance."},
    {"position":"-0.1 0.015 -0.62","normal":"0 1 0","label":"Woven Cord and Fastening","description":"The ornaments are secured using a woven cord traditionally made from materials such as rattan and runo reeds. The cord holds the pieces together and allows the necklace to be worn around the neck."}
  ]$json$::jsonb,
  updated_at = now()
where slug = 'baoya';

update public.artifacts set
  details = $json$[
    {"heading":"Tactical Purpose","text":"Used as a defensive shield against enemy weapons such as spears and axes. Its pointed prongs could also help trip, pin, or restrain opponents during close combat."},
    {"heading":"Materials Used","text":"Carved from lightweight native hardwoods such as dapdap, polay, or sablang. The shield is reinforced with woven rattan (uway) bands and coated with dark resin for added strength and protection."},
    {"heading":"References","text":"Mallari, P. G. S. (2018, May 8). Kalasag: The Filipino War Shield - FMA Pulse. FMA Pulse. https://fmapulse.com/fma-corner/fma-corner-kalasag-filipino-war-shield/"}
  ]$json$::jsonb,
  hotspots = $json$[
    {"position":"0 0.9 -0.025","normal":"0 0 -1","label":"Pointed Prongs","description":"The Kalasag features pointed wooden prongs at both ends, which could be used to trap, pin, or restrain an opponent's weapons during close combat."},
    {"position":"0.2 0.25 0.015","normal":"0 0 -1","label":"Wooden Body","description":"The shield is traditionally carved from native hardwood, providing a sturdy defensive surface against weapons such as spears and axes while remaining manageable during combat."},
    {"position":"0 0.015 -0.015","normal":"0 0 1","label":"Wooden Handle","description":"The handle allows the warrior to firmly grip and maneuver the Kalasag during combat, providing better control when blocking or deflecting incoming attacks."}
  ]$json$::jsonb,
  updated_at = now()
where slug = 'kalasag';

update public.artifacts set
  animation_name = 'Armature|mixamo.com|Layer0',
  autoplay = true,
  loop = true,
  updated_at = now()
where slug = 'atang';
