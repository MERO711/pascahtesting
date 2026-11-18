# PASCCAH System Documentation

## Project overview

PASCCAH (Preserve, Access, Share, Cordilleran Cultures and Heritages) is a
static website for exploring cultural heritage collections from the six
provinces of the Cordillera Administrative Region. Visitors can browse
province archives and explore cultural artifacts and values through
interactive 3D models, descriptions, hotspots, optional audio, and augmented
reality (AR).

The site is built from HTML, CSS, and browser-side JavaScript modules. It has
no application server or build step. Supabase supplies archive and artifact
metadata; the model and image/audio assets are served as static files.

## User-facing pages and navigation

1. `index.html` is the landing page and links visitors to the map and About Us.
2. `map.html` presents links to the Abra, Apayao, Benguet, Ifugao, Kalinga,
   and Mountain Province archives.
3. Each `<province>-archive.html` page shows the province's Artifact and Value
   collections. Visitors can switch categories and filter items alphabetically.
4. Selecting an item opens `artifact.html?id=<slug>`, which loads that item's
   content and 3D model.
5. `about.html` introduces the project team.

The older item-specific HTML pages (for example, `abra-lagpi.html`) remain in
the repository for direct-link compatibility. They load
`artifact-redirect.js`, which redirects recognized item paths to the shared
artifact viewer.

## Architecture

### Browser application

- HTML files define page structure and accessible controls.
- Styles are organized by page type: `home.css`, `map.css`, `archive.css`,
  `viewer.css`, and `about.css`.
- `archive.js` fetches and renders province collection data, builds category
  tabs and A–Z filters, and retains the archive HTML as fallback content if
  Supabase is unavailable.
- `artifact-page.js` validates the `id` query parameter, fetches one artifact,
  renders its details and hotspots, and configures the 3D viewer and audio.
- `viewer.js` implements viewer interactions including hotspot expansion,
  audio playback, animation controls, load/error status, and fullscreen.
- `artifact-redirect.js` maps legacy item URLs to the shared viewer.

### External browser dependencies

- Supabase JavaScript client v2 is imported from `esm.sh` by
  `supabase-client.js`.
- The `<model-viewer>` web component v4.1.0 is loaded from Google Hosted
  Libraries by the viewer pages.
- These dependencies are loaded at runtime from their CDNs; there is no local
  package manifest or dependency installation step in the current project.

### Supabase data access

`supabase-config.js` provides the project URL and browser-safe publishable
key. `supabase-client.js` lazily creates and caches the client. The browser
uses the `anon`/publishable role to read public artifact data; a service-role
or secret key must never be placed in frontend code.

The `public.artifacts` table is the content source for archive listings and
the shared viewer. The setup script enables row-level security and defines a
public read-only policy for `anon` and `authenticated` users. It seeds 13
items across the six provinces: 12 Artifacts and one Value (Atang).

Key fields:

| Field | Purpose |
| --- | --- |
| `slug` | Stable URL identifier; primary key used by `artifact.html?id=...`. |
| `name`, `province`, `category` | Display name and archive grouping. Category is `Artifact` or `Value`. |
| `subtitle`, `description` | Summary content shown in the archive; the subtitle is also used in the viewer metadata. |
| `model_path` | Relative path to the item's 3D model. |
| `audio_path` | Optional relative path to an audio asset. |
| `archive_path` | Destination for the viewer's return link. |
| `details` | JSON array of heading/text entries for the item information panel. |
| `hotspots` | JSON array of 3D positions, normals, labels, descriptions, and optional audio behavior. |
| `animation_name`, `autoplay`, `loop` | Optional model animation configuration. |

Archive pages select records by province and order them by name. The viewer
looks up one record by slug. If the archive fetch fails, the page reports the
problem and keeps the saved HTML entries visible. If an artifact cannot be
loaded, the viewer displays an error status.

## Repository map

| Path | Contents |
| --- | --- |
| `index.html`, `map.html`, `about.html` | Landing, province map, and team pages. |
| `*-archive.html` | Archive page shells for the six provinces. |
| `artifact.html` | Shared database-driven artifact viewer. |
| `*-<item>.html` | Legacy item pages that redirect to the shared viewer. |
| `archive.js`, `artifact-page.js`, `artifact-redirect.js`, `viewer.js` | Archive data loading, viewer data loading, legacy redirects, and viewer interactions. |
| `supabase-client.js`, `supabase-config.js` | Browser Supabase client setup and project configuration. |
| `supabase-setup.sql` | Creates/updates the artifacts table, read policy, and seeded collection data. |
| `SUPABASE_SETUP.md` | Supabase project setup and deployment instructions. |
| `3D ASSETS/`, `3D ASSETS VALUES/` | GLB 3D models used by artifacts and values. |
| `Audio Assets/` | Audio used by viewer interactions. |
| `Cordi Map/`, `Logo/` | Map images, province labels, and site logo. |
| `Testing/`, `placeholder_assets/` | Standalone viewer test pages and their sample models. |

## Setup and running

1. Configure a Supabase project URL and publishable/anon key in
   `supabase-config.js`.
2. Run `supabase-setup.sql` in the Supabase SQL Editor to create/update the
   table and seed the current collection.
3. Serve the repository root over HTTP or HTTPS using a static host or local
   development server. Opening the files directly with `file://` is not
   supported because the application uses JavaScript modules.
4. Keep model and audio files at the relative paths stored in Supabase, or
   update those records when moving assets.

See [SUPABASE_SETUP.md](./SUPABASE_SETUP.md) for the full backend setup steps
and key-handling guidance.

## Content maintenance

### Adding an artifact or value to an existing province

The shared archive and viewer scripts already handle new records. For an item
in one of the six existing provinces, update the content and assets rather
than creating another viewer page or changing JavaScript.

| What to edit | Where | What to change |
| --- | --- | --- |
| Live catalog entry | Supabase `public.artifacts` table | Add a row with a unique lowercase `slug`, exact province name, `category` (`Artifact` or `Value`), name, subtitle, description, relative `model_path`, and `archive_path`. Set `audio_path` if needed. |
| Repeatable setup data | `supabase-setup.sql` | Add the matching row to the `INSERT INTO public.artifacts ... VALUES` list. Add a matching `UPDATE public.artifacts` block for `details` and `hotspots`; add animation settings in another update block if needed. Comments mark both edit locations. |
| 3D model | `3D ASSETS/` or `3D ASSETS VALUES/` | Add the `.glb` file and make `model_path` exactly match its path from the site root. |
| Optional audio | `Audio Assets/` and the database row | Add the audio file, set `audio_path`, and set the relevant hotspot's `"audio": true` if the audio should play when that hotspot is selected. |
| Offline/error fallback card | The matching `<province>-archive.html` | Add an archive card inside the correct Artifact or Value `.archive-items` list. Use `href="artifact.html?id=<slug>"` and keep its displayed name, subtitle, province, category, and description consistent with the database. HTML comments mark both lists. |

#### Recommended sequence

1. Choose a unique slug, add the model (and optional audio) file, and note
   their paths relative to the repository root.
2. Add the record to the live Supabase table. The `province` must exactly
   match the archive heading (for example, `Mountain Province`); `category`
   determines whether the item appears under Artifacts or Values.
3. Fill in `details` as an array of `{ "heading": "...", "text": "..." }`
   objects. Fill in `hotspots` as an array of objects with three-number
   position and normal strings, labels, and descriptions. Set animation fields
   only when the model includes a matching animation.
4. Add the same record and viewer data to `supabase-setup.sql` if the setup
   script should reproduce the content in a new or rebuilt database.
5. Add a matching HTML fallback card to the province archive. The live
   database list replaces these saved cards after a successful load, but the
   cards remain useful if the data request fails.
6. Serve the site over HTTP(S) and check the archive tab and
   `artifact.html?id=<slug>`.

The SQL script is seeded content, not a live synchronization mechanism: edits
to that file affect Supabase only when the script is run. Existing
item-specific HTML pages redirect to the shared viewer, so a new item does
not need its own `<slug>.html` page. Do not edit `archive.js`,
`artifact-page.js`, or `viewer.js` for ordinary content additions.

Adding a province is a separate change: it also requires a new archive page
and a province link on `map.html`.

## Current scope and constraints

- The website is read-only from the browser; content changes are managed in
  Supabase or the repository, not through an admin interface.
- AR availability depends on the device and browser support for the
  `<model-viewer>` AR modes.
- The static pages, CDN-loaded libraries, Supabase project, and referenced
  assets must all be reachable for the complete experience.
- The standalone pages in `Testing/` are for model-viewer experiments and are
  not part of the main visitor navigation.
