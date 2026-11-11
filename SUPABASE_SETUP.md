# Supabase setup

The site remains static HTML and JavaScript. The shared client uses the
Supabase JavaScript SDK from a CDN, so no build step or package install is
needed. Artifact archive links now open the shared `artifact.html?id=<slug>`
viewer instead of requiring a separate viewer page per item. The old individual
page URLs redirect to the shared viewer. The viewer fetches artifact descriptions,
purpose/material details, model and audio paths, animation settings, and hotspot
positions/content from Supabase. Province archive lists are also loaded from
Supabase; their existing HTML entries remain visible as a fallback if the
database is unavailable.

## Configure Supabase

1. Create a project in the Supabase dashboard.
2. In **Project Settings → API**, copy the project URL and its **publishable
   key** (or legacy `anon` key).
3. Add them to `supabase-config.js`:

   ```js
   export const SUPABASE_URL = 'https://your-project-id.supabase.co';
   export const SUPABASE_ANON_KEY = 'your-publishable-or-anon-key';
   ```

4. Open the Supabase **SQL Editor**, paste in `supabase-setup.sql`, and run it.
   The script creates or updates the `artifacts` table, enables row-level
   security, grants public read-only access through an RLS policy, and seeds
   all 13 archive entries and their viewer details and hotspots. It is
   idempotent and can be run again to update those records. If you already ran
   an earlier version of this setup, run the updated script again to add the
   viewer-detail and hotspot columns.
5. Serve the site over HTTP or HTTPS, such as with GitHub Pages or a local
   development server. ES modules do not work reliably from a `file://` URL.

The asset paths in the seed data point to the existing model/audio files in the
site repository. Keep those files at the same paths, or update each record's
`model_path` and `audio_path` in Supabase if you move them.

The publishable/anon key is intended for browser use. **Never put a service-role
key or secret key in this file or any frontend code.** The provided RLS policy
allows visitors to read artifact data only; it does not allow browser-side
inserts, updates, or deletes.
