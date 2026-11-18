# How artifact details and hotspots are displayed

This guide explains how a URL such as `artifact.html?id=lagpi` loads one row
from Supabase, shows its written details, and places clickable hotspots on its
3D model.

## The flow at a glance

1. An archive link opens `artifact.html?id=<slug>`. The slug is the artifact's
   `slug` value in the `artifacts` table, such as `lagpi`.
2. [`artifact.html`](../artifact.html) provides empty page elements for the
   artifact name, details, status message, and 3D viewer.
3. [`artifact-page.js`](../artifact-page.js) reads the slug, requests the
   matching Supabase row, then fills those page elements.
4. The `details` field becomes text in the sidebar. The `hotspots` field
   becomes numbered buttons attached to the 3D model.
5. [`viewer.js`](../viewer.js) handles clicks on those buttons. The hotspot
   description expands when selected.

## 1. The URL chooses the artifact

For example:

```text
artifact.html?id=lagpi
```

In `loadArtifact()`, this line reads `lagpi` from the URL:

```js
const slug = new URLSearchParams(window.location.search).get('id')?.trim();
```

The next check accepts only lowercase letters, numbers, and hyphens. If the
value is missing or invalid, the page displays an error instead of querying
the database.

## 2. The page requests the row from Supabase

`getSupabaseClient()` in [`supabase-client.js`](../supabase-client.js) creates
the browser's Supabase client using the URL and publishable/anon key in
[`supabase-config.js`](../supabase-config.js).

The query in `loadArtifact()` is:

```js
const { data: artifact, error } = await supabase
  .from('artifacts')
  .select('slug, name, province, category, subtitle, model_path, audio_path, archive_path, details, hotspots, animation_name, autoplay, loop')
  .eq('slug', slug)
  .maybeSingle();
```

Line by line:

- `.from('artifacts')` selects the `artifacts` table.
- `.select(...)` asks Supabase for the listed columns, including `details` and
  `hotspots`.
- `.eq('slug', slug)` keeps only the row whose `slug` matches the URL.
- `.maybeSingle()` returns one row, or `null` if there is no match.
- `{ data: artifact, error }` names the returned row `artifact` and captures
  any query error.

The code then stops with a visible message if the query failed or no row
matched. Otherwise, `artifact` contains the selected row and its JSON fields.

## 3. The `details` JSON becomes sidebar text

The page has an empty `<div id="artifact-details">` in `artifact.html`.
`artifact-page.js` passes the row's details to:

```js
renderDetails(artifact.details);
```

`renderDetails()` expects an array. For each entry, it:

1. Checks that `heading` and `text` are strings.
2. Creates a paragraph and a bold heading.
3. Adds the heading and text to the paragraph.
4. Appends that paragraph to `#artifact-details`.

For example, this database value:

```json
[
  {
    "heading": "Purpose",
    "text": "Used to carry seeds and harvested crops."
  },
  {
    "heading": "Materials Used",
    "text": "Traditionally made from woven rattan."
  }
]
```

appears in the sidebar as:

- **Purpose:** Used to carry seeds and harvested crops.
- **Materials Used:** Traditionally made from woven rattan.

The renderer uses `textContent` and appends text, rather than treating the
database text as HTML.

## 4. The `hotspots` JSON becomes buttons on the model

After setting the model URL with `viewer.src`, the page calls:

```js
renderHotspots(artifact.hotspots);
```

`renderHotspots()` loops over the JSON array. For each hotspot it checks for
valid `position` and `normal` 3D vectors, plus string `label` and
`description` values. It then creates a button containing a number and a
label.

Example database value:

```json
[
  {
    "position": "-0.1 0.85 0",
    "normal": "0 1 0",
    "label": "Carrying Straps",
    "description": "Woven straps make the container easier to carry."
  }
]
```

The important button attributes created from that entry are:

```js
button.slot = `hotspot-info-${index + 1}`;
button.dataset.position = hotspot.position;
button.dataset.normal = hotspot.normal;
```

- `slot` tells `<model-viewer>` to treat this button as a model hotspot.
- `data-position` gives the hotspot's 3D position on the model.
- `data-normal` gives the direction the hotspot faces at that position.
- `index + 1` is also displayed inside the button, so the first hotspot is
  numbered `1`.

The button's visible label is built from `label` and `description`, then
inserted inside the `<model-viewer>` element before its AR button. Once the
model and hotspots are ready, the code unhides the viewer and hides the
loading/status message.

The coordinates are specific to the model. If a hotspot appears in the wrong
place, adjust its `position` and, if needed, its `normal` in the matching
Supabase row.

## 5. Clicking a hotspot reveals its description

`viewer.js` listens for clicks on the whole viewer. When the click came from a
`.model-hotspot` button, it:

1. Closes any other expanded hotspot.
2. Toggles the clicked button's `is-expanded` class.
3. Updates `aria-expanded` for assistive technology.

In [`viewer.css`](../viewer.css), this rule displays the label only while its
hotspot is expanded:

```css
.model-hotspot.is-expanded .hotspot-label {
  display: inline-block;
}
```

If a hotspot entry has `"audio": true`, the page also connects it to the
`#artifact-audio` element. Selecting that hotspot plays the audio file set by
the row's `audio_path`.

## Data locations

- The table, JSON array constraints, and seeded artifact data are in
  [`supabase-setup.sql`](../supabase-setup.sql).
- The Supabase project URL and browser-safe key are in
  [`supabase-config.js`](../supabase-config.js).
- The row lookup and rendering code are in
  [`artifact-page.js`](../artifact-page.js).
- Hotspot click behavior is in [`viewer.js`](../viewer.js), and its appearance
  is in [`viewer.css`](../viewer.css).

If the sidebar or hotspots are empty, check that the URL's `id` matches a row's
`slug`, that the row has populated `details` and `hotspots` arrays, and that
the Supabase configuration is correct. The browser console reports query and
data-validation errors.
