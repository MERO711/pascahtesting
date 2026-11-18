# Beginner's Guide to the PASCCAH Code

This guide explains the project files in everyday language. You do not need to
understand every line to make safe content changes.

## The short version

Think of the website as a small exhibit:

- **HTML** is the exhibit's structure: headings, links, buttons, and panels.
- **CSS** is its appearance: colors, sizes, spacing, and how it adapts to a
  phone.
- **JavaScript** makes it respond: loading archive items, opening a viewer,
  playing audio, and reacting to clicks.
- **Supabase** is the online catalog that stores item information.
- **SQL** is a language for setting up or changing that catalog.
- **3D and audio files** are the media shown or played by the website.

The normal visitor journey is:

1. `index.html` displays the home page.
2. `map.html` links to one of the six province archives.
3. A province archive gets its item list from Supabase.
4. Selecting an item opens `artifact.html?id=<slug>`. The `slug` is the item's
   short, unique ID, such as `lagpi`.
5. The viewer loads the item's text, model, hotspots, and optional audio.

## Which files do what?

### Pages and appearance

| File or group | In everyday language |
| --- | --- |
| `index.html`, `map.html`, `about.html` | The home, map, and team pages. They define what appears on those pages. |
| `*-archive.html` | The six province archive page layouts. Each also contains saved item cards as a backup. |
| `artifact.html` | The shared viewer layout used for every item. The `id` in its web address tells it which item to show. |
| `home.css` | The look of the home page. |
| `map.css` | The look and positioning of the province map links. |
| `archive.css` | The look of province archive pages and their item cards. |
| `viewer.css` | The look of the 3D viewer and its information panel. |
| `about.css` | The look of the About Us page. |

### Actions and data

| File | In everyday language |
| --- | --- |
| `archive.js` | Gets a province's items from Supabase and fills the archive lists. It also makes the category tabs and letter filters work. |
| `artifact-page.js` | Reads the item's `slug` from the web address, gets its data, and puts that data into the shared viewer. |
| `viewer.js` | Makes viewer controls work, such as hotspots, animation, audio, and fullscreen. |
| `artifact-redirect.js` | Sends visitors from an older item-specific address to the shared viewer. |
| `supabase-client.js` | Connects the website to Supabase. Most content editors do not need to change it. |
| `supabase-config.js` | Holds the Supabase project address and browser-safe public key. Do not put a secret or service-role key here. |
| `supabase-setup.sql` | Creates the catalog table and contains the starter item data used to set up or reseed the database. |
| `SUPABASE_SETUP.md` | Explains how to configure Supabase and serve the website. |

## JavaScript: a closer look at every file

There are six JavaScript files in the main project, including one small
configuration file. They work together, but each has a different job. The
words below are the names used in the code so you can search for them in VS
Code.

### `archive.js` — fill and control a province archive

This file is loaded by the six `*-archive.html` pages.

1. **Find the page controls.** Near the top, `querySelectorAll` finds the
   Artifact and Value tabs and their panels in the HTML.
2. **Build one item card.** `createArchiveItem(artifact)` takes one database
   item and creates its link, name, subtitle, description, province, and type.
   The link points to `artifact.html?id=<slug>`.
3. **Put items into the right list.** `populatePanels(artifacts)` separates
   items by category, then fills the Artifact and Value panels.
4. **Make the letter filters work.** `initializeFilters()` counts the items,
   creates the All and A–Z buttons, disables letters with no matches, and
   hides items that do not match the selected letter.
5. **Make tabs and scroll buttons work.** `selectTab()` shows one category
   panel at a time. The keyboard and scroll listeners let visitors use the
   controls without clicking every button.
6. **Load this province's data.** `loadArchive()` reads the archive heading
   (such as `Abra Archive`), asks Supabase for that province's records, and
   orders them by name. If the request fails, it displays a message and leaves
   the saved HTML cards in place. It then sets up the filters.

The final `loadArchive()` line starts this process when the script is loaded.
To change the way a card looks, use `archive.css`. To change which data is
displayed, update Supabase rather than changing the card-building code.

### `artifact-page.js` — load data for one item

This file is loaded by `artifact.html`.

1. **Connect code to page areas.** The constants at the top find the name,
   details area, back link, 3D viewer, audio element, and animation button by
   their HTML IDs.
2. **Prepare the details text.** `renderDetails(details)` checks that details
   are a list of heading/text entries, clears the old content, and creates a
   paragraph for each entry.
3. **Prepare model hotspots.** `isVector(value)` checks that a position or
   direction has three numeric values. `renderHotspots(hotspots)` checks each
   hotspot and creates a numbered button for it on the 3D model.
4. **Find the requested item.** `loadArtifact()` reads the `id` after the `?`
   in the web address, for example `lagpi` in
   `artifact.html?id=lagpi`. It checks that the ID is valid, then asks
   Supabase for the matching row.
5. **Fill the viewer.** If the row exists, the function sets the displayed
   name and details, return link, model file, audio file, hotspots, and
   animation settings.
6. **Show problems clearly.** `showError(...)` changes the page to say that
   the item is unavailable. The `try/catch` around loading catches connection
   or data errors and shows a helpful message.

The final `loadArtifact()` line starts the data-loading process. For a new
item, its database fields and files supply the content; this JavaScript is
shared by all items.

### `viewer.js` — respond to 3D viewer actions

This file is also loaded by `artifact.html` and the older item pages. It
controls actions, not the database lookup.

- **AR button:** if the model has an animation, clicking the AR control starts
  it and updates the animation button label.
- **Hotspot clicks:** a click listener watches the viewer for a
  `.model-hotspot` button. It opens the selected hotspot and closes the others.
  If that hotspot is marked for audio, it restarts and plays the audio.
- **Model loaded:** `handleViewerLoad()` hides the loading message and updates
  the animation button based on the item's category and whether the model
  actually contains an animation.
- **Model error:** an error listener replaces the loading message and marks
  the animation as unavailable.
- **Play/pause:** the animation button tells the model to play or pause and
  changes its label.
- **Fullscreen:** the fullscreen button enters or exits fullscreen mode.

If a control is present in HTML but does nothing, this is one of the files to
check. If the text, model, or hotspot itself is wrong, first check the
Supabase item data.

### `supabase-client.js` — make the Supabase connection

Other JavaScript files call `getSupabaseClient()` when they need database
data. This function:

1. Reads the URL and public key from `supabase-config.js`.
2. Stops with an error if either setting is blank.
3. Downloads the Supabase JavaScript library from its CDN the first time it is
   needed and creates a client.
4. Reuses that client for later requests rather than creating a new one each
   time.

If connecting fails, it clears the failed attempt so a later try can work.
Most content changes do not require editing this file. Never put a secret or
service-role key in the browser configuration.

### `supabase-config.js` — tell the site which Supabase project to use

This short file exports two settings: the Supabase project URL and its
publishable (public browser) key. `supabase-client.js` reads these settings
when it makes a connection.

Change these values only when connecting the site to a different Supabase
project. The publishable key is intended for website use; do not put a
service-role or other secret key here.

### `artifact-redirect.js` — support older item links

This small file handles an old address such as `abra-lagpi.html`:

1. It reads the current filename from the browser address.
2. It removes `.html` and a known province prefix, leaving the item slug
   (`lagpi`).
3. It checks that the slug contains only lowercase letters, numbers, and
   hyphens.
4. It sends the browser to `artifact.html?id=lagpi`.

This is why a new item normally does not need its own old-style HTML page.

### Common JavaScript words in this project

| Code phrase | Plain meaning |
| --- | --- |
| `const name = ...` | Save a value under a name so this file can use it later. |
| `document.getElementById(...)` | Find one page element by its HTML `id`. |
| `document.querySelector(...)` | Find the first page element matching a selector. |
| `addEventListener('click', ...)` | Run an action when someone clicks an element. |
| `async` / `await` | Let the code wait for something that takes time, such as a database response. |
| `try` / `catch` | Try an operation and handle a problem if it fails. |
| `textContent` | Read or set the plain text inside a page element. |
| `hidden` | Show or hide a page element. |
| `dataset` | Read or store extra values attached to an HTML element. |

## Understanding the four main code types

### HTML: what is on a page

HTML is made of named pieces. For example, a heading is written as an `h1`,
and a link is written as an `a` element.

In the archive pages, the element with the `archive-items` class is the area
where item cards appear. The `href` on a card tells the browser which page to
open. A link like `artifact.html?id=lagpi` opens the shared viewer and passes
it the `lagpi` ID.

The comments marked **Saved HTML fallback** in each archive page point to
backup cards. The site normally replaces these with the live Supabase list.
The saved cards are still useful if the database cannot be reached.

### CSS: how a page looks

CSS rules match pieces of HTML and describe how they should look. A rule
starting with `.archive-items` applies to elements marked with the
`archive-items` class. A rule starting with `@media` adjusts the design for
different screen sizes, such as phones.

To look for a visual change, start with the CSS file for that page type. For
example, archive card spacing is in `archive.css`; the 3D viewer layout is in
`viewer.css`. CSS changes appearance, not item descriptions or database data.

### JavaScript: what a page does

JavaScript reads the page, gets data, and responds to visitor actions. In this
project:

- `archive.js` asks Supabase for items matching the province name on the
  archive page.
- `artifact-page.js` asks for the item whose slug matches the viewer's web
  address.
- `viewer.js` listens for actions such as clicking a hotspot or fullscreen
  button.

You usually do not need to change these files just to add an item. They are
shared so one set of behavior works for all items.

### SQL: how the catalog is stored

Supabase stores item information in a table named `artifacts`. Think of a
table as a spreadsheet: each item is a row, and each type of information is a
column.

The SQL file contains several kinds of instructions:

- `CREATE TABLE` describes the columns the catalog needs.
- `INSERT` adds or refreshes the basic seeded item records.
- `UPDATE` fills in extra viewer data, such as details, hotspots, and
  animation settings.
- The access policy allows the public website to read the catalog.

The comments in `supabase-setup.sql` mark where to add a catalog row and its
viewer details. Editing the SQL file alone does not change the live website:
the SQL must be run in Supabase. For an immediate live content change, update
the Supabase table directly; update the SQL seed too if you want the setup
script to contain that item for future setup.

## Adding an item: which places need attention?

For an artifact or value in a province that already exists:

1. **Add the live catalog row** in Supabase `public.artifacts`. Give it a
   unique lowercase `slug`, the exact province name, and category `Artifact`
   or `Value`.
2. **Add the media file** to `3D ASSETS/` or `3D ASSETS VALUES/`. Put its
   site-relative path in `model_path`. Add audio under `Audio Assets/` and
   provide `audio_path` only if the item uses audio.
3. **Add the item's viewer information** to the row: `details` for the text
   panel, `hotspots` for numbered model callouts, and animation settings only
   if the model has an animation.
4. **Update `supabase-setup.sql`** with the same item if the setup script
   should be able to recreate it later. The comments identify the seed row
   area and the viewer-details update area.
5. **Update the matching `<province>-archive.html` fallback card** so the
   item can still appear if the database request fails. The comments above
   each Artifact and Value list mark where those cards go.
6. **Check the result** on the province archive and at
   `artifact.html?id=<slug>`.

You normally do **not** create a new item HTML page or edit JavaScript or CSS
for an ordinary item addition. If adding a brand-new province, that also
requires a new archive page and a link on `map.html`.

## A few words you may see

| Word | Simple meaning |
| --- | --- |
| `slug` | A short unique ID used in the item's web address, such as `lagpi`. |
| `path` | The location of a file, such as `3D ASSETS/abra-lagpi.glb`. |
| `class` | A label on HTML that CSS and JavaScript use to find or style a group of elements. |
| `id` | A unique label for a page element, or in this project, the item ID after `?id=` in the web address. |
| `JSON` | A structured way to write groups of data, used here for details and hotspots. |
| `fallback` | Backup content shown if the preferred live data cannot be loaded. |
| `CDN` | An external web address from which the site downloads a library it needs. |

## A gentle way to learn the project

Start with one item, such as Lagpi:

1. Find its card in `abra-archive.html`.
2. Notice that the card links to `artifact.html?id=lagpi`.
3. Find the `lagpi` row in `supabase-setup.sql` and see how it points to the
   model file.
4. Find the `lagpi` viewer-details update in that SQL file.
5. Follow the flow in this guide: archive page → item ID → Supabase data →
   shared viewer.

You can read and explore without changing anything. When you do make changes,
work on a copy or preview the site using a local web server; the project uses
browser modules and is not intended to be opened directly as a `file://` page.
