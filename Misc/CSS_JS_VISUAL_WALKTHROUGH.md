# How the CSS and JavaScript Create the PASCCAH Website

This guide follows the project's actual CSS and JavaScript, in file order. It
explains what the main code sections do and how they lead to things a visitor
can see or interact with. It is meant to be read beside the source files in VS
Code.

You do not need to memorize every property or statement. Try to understand the
path from a page element, to the code that changes or styles it, to the result
in the browser.

## The short version: how a page becomes a visual screen

The browser combines four kinds of things:

1. **HTML** supplies the page's elements: headings, links, buttons, panels,
   images, and the 3D viewer.
2. **CSS** selects those elements and describes their appearance and layout:
   color, size, spacing, position, and behavior at different screen sizes.
3. **JavaScript** finds elements, gets data, listens for user actions, and
   changes text, attributes, or classes. Those changes can make CSS show a
   different visual state.
4. **Assets and data** supply the actual pictures, 3D models, audio, and
   collection text.

For example, the archive HTML contains an `.archive-items` area. The archive
script puts item cards into that area. The archive stylesheet sees the
`archive-item` class on each card and draws the bordered, colored card. When a
visitor picks a letter, JavaScript hides nonmatching cards; the browser then
redraws the remaining cards.

**CSS does not fetch the collection or invent the text. JavaScript does not
draw the site's colors by itself.** JavaScript supplies or changes page
elements and states; CSS determines how those states look.

## A few terms used below

| Term | Plain-language meaning |
| --- | --- |
| **Element** | One piece of a page, such as a heading, image, or button. |
| **Selector** | The part of a CSS rule that says which elements it styles. `.team-card` selects elements with that class; `h1` selects headings. |
| **Class** | A reusable label on an HTML element. CSS and JavaScript use it to identify groups of elements. |
| **Property and value** | A CSS instruction and its setting, such as `color: red`. |
| **DOM** | The browser's in-memory representation of the HTML page. JavaScript can find and update it. |
| **Event listener** | Code that waits for something, such as a click or a model-load event. |
| **Attribute** | Information on an HTML element, such as `href`, `hidden`, or `aria-selected`. |
| **Responsive rule** | CSS inside `@media` that applies only at certain screen widths or when a device preference applies. |

## Main data-to-screen journeys

### Browsing a province archive

1. A province archive HTML page supplies the tabs, panel areas, and saved
   fallback cards.
2. `archive.js` reads the province name from the page heading and requests
   that province's item rows from Supabase.
3. On success, JavaScript creates item-card elements and puts them in the
   Artifact or Value panel.
4. `archive.css` styles their classes into cards, tabs, filter buttons, and a
   scrollable list.
5. Clicks and keyboard arrows change which panel or cards are visible.

### Opening and exploring one artifact

1. An archive card links to `artifact.html?id=<slug>`, where `<slug>` is a
   short item ID.
2. `artifact-page.js` reads that ID and asks Supabase for that item's data.
3. It puts the text and model path into elements from `artifact.html`.
4. The `<model-viewer>` component loads and displays the GLB model.
5. `viewer.js` handles hotspot clicks, optional audio, animation, and
   fullscreen. `viewer.css` styles the text column, model area, hotspots, and
   controls.

## JavaScript: what each script does

### `archive.js` — load and operate the province archive

Open [archive.js](./archive.js). The sections below follow the file from top
to bottom.

#### Lines 1–5: import the database helper and find page controls

- **Line 1** imports `getSupabaseClient`. This is the shared helper that
  connects to Supabase.
- **Line 3** turns the alphabet into an array, so the script can create one
  filter button for each letter.
- **Line 4** finds every element marked as a tab.
- **Line 5** finds every archive category panel.

These lines do not draw anything yet. They save references to page elements so
later code can work with them.

#### Lines 7–48: `createArchiveItem(artifact)` builds one visible card

- `document.createElement(...)` makes new HTML elements in the browser.
- The outer `<a>` is given the classes `archive-item` and
  `archive-item-link`. The CSS uses those class names to make it look like a
  card and behave like a link.
- `link.href` points to the shared viewer and includes the item's `slug`.
  `encodeURIComponent` makes the slug safe to put into a URL.
- The script creates a header, name, subtitle, description, and metadata
  elements. Their `textContent` values come from the artifact record.
- A loop creates the Province and Type metadata from the same small template.
- It creates the “View Item” label and arrow, adds all the pieces to the
  correct parent elements with `append`, then returns the finished link.

The card becomes visible only after another function adds this returned
element to the page. Its class names connect it to the visual rules in
`archive.css`.

#### Lines 50–67: `populatePanels(artifacts)` sorts cards into the two lists

- A `Map` stores one temporary group for `Artifact` and one for `Value`.
- `forEach` visits each database record. The category selects which group
  receives the card made by `createArchiveItem`.
- A `DocumentFragment` is a temporary container. Building cards there and
  placing them in the page together avoids repeatedly updating the visible
  list one card at a time.
- The final loop finds the right panel's `.archive-items` area and
  `replaceChildren` puts the new cards there.

That last action updates the browser's page. CSS then lays out the new cards.

#### Lines 69–103: `initializeFilters()` creates and runs the A–Z filters

- For each panel, the script collects its cards, alphabet-bar area, and item
  count.
- It reads the first letter of each card heading and saves the letters that
  actually occur in a `Set`.
- It writes the card count into the page.
- It creates an **All** button and A–Z buttons. A letter with no matching
  cards is disabled.
- Each button gets a click listener. On a click, the script updates
  `aria-pressed` on all filter buttons, then sets `item.hidden` for cards
  whose first letter does not match.
- It scrolls the card list back to the top so visitors see the filtered
  results.

The CSS rule `.alphabet-button[aria-pressed="true"]` gives the selected
button its active appearance. The browser hides an element with the `hidden`
property, so no separate drawing code is needed to remove filtered cards from
view.

#### Lines 105–125: `selectTab()` and keyboard tab controls

- `selectTab(selectedTab)` checks each tab to see whether it is the selected
  one.
- It updates `aria-selected` and `tabIndex`, which describe the selected tab
  and keyboard focus state.
- It finds the panel named in each tab's `aria-controls` attribute and sets
  its `hidden` property. Only the selected category panel remains visible.
- The click listener selects the clicked tab.
- The keyboard listener supports the left and right arrow keys. It wraps from
  the last tab to the first, selects the next tab, and moves keyboard focus.

The CSS selector `.archive-tab[aria-selected="true"]` styles the selected tab.
The `hidden` attribute controls which panel is displayed.

#### Lines 127–137: scroll buttons

- The script finds buttons marked with `data-scroll`.
- When a visitor clicks one, it finds that button's containing panel and item
  list.
- `data-scroll="down"` means move down; otherwise move up.
- `scrollBy` moves the list smoothly by most of its visible height.

The CSS makes `.archive-items` a limited-height scroll area and styles the
separate up/down buttons.

#### Lines 139–end: `loadArchive()` gets the province's records

- It reads the heading, such as `Abra Archive`, then removes the word
  “Archive” to get the province name.
- Inside `try`, it checks that a province name was found, gets the Supabase
  client, and requests the fields needed for archive cards.
- `.eq('province', province)` asks for only records belonging to that
  province; `.order('name')` sorts them by name.
- If Supabase reports an error, the code throws it so the `catch` block can
  handle the failure.
- If the request succeeds, `populatePanels(data)` displays the results.
- If the request fails, the code logs the error and adds a status message.
  The saved cards in the HTML remain in place because they are only replaced
  after a successful request.
- `initializeFilters()` runs after either outcome, so the saved cards can
  still be filtered when the database is unavailable.
- The last `loadArchive()` call starts the process when the script loads.

### `artifact-page.js` — fill the shared artifact viewer with one record

Open [artifact-page.js](./artifact-page.js).

#### Lines 1–10: find the viewer's HTML elements

The `getElementById` calls save references to the artifact title, metadata,
details, status message, return link, animation button, 3D viewer, and audio
player. The IDs match the elements in `artifact.html`. Later code changes
those elements instead of making a separate viewer page for every artifact.

#### Lines 12–29: `renderDetails(details)` creates the text details

- The function checks that `details` is a list.
- It clears the current details area.
- For each detail, it checks that a heading and text are present.
- It creates a paragraph and bold heading, adds the text, and puts the
  paragraph into the details area.

Those paragraphs are styled by `.content-section` and `.content-section p`
in `viewer.css`.

#### Lines 31–36: `isVector(value)` checks hotspot coordinates

A 3D hotspot needs three numbers, one for each direction in 3D space. This
function splits the coordinate string into pieces and confirms there are
exactly three valid numbers. It checks the input shape; it does not draw the
hotspot.

#### Lines 38–89: `renderHotspots(hotspots)` adds numbered model markers

- The function checks that hotspots are a list, then loops through them.
- It validates each hotspot's position, normal, label, and description before
  using them.
- It creates a button with the `model-hotspot` class and supplies the
  position/normal data needed to place it on the 3D model.
- It creates a numbered circle and a label containing the hotspot text.
- If the hotspot is marked for audio, it stores the audio element's ID on the
  button.
- It inserts each button inside the model viewer.

The 3D component uses the hotspot position to place the button over the model.
`viewer.css` styles the button as a numbered marker. Its label starts hidden;
`viewer.js` later adds a class when the visitor opens it.

#### Lines 91–95: `showError(...)` reports a problem

This helper writes a useful message in the page and changes the title to
“Artifact unavailable.” It also sends the underlying error to the browser
console for troubleshooting.

#### Lines 97–end: `loadArtifact()` loads and displays the requested record

- It reads the `id` value from the page URL and checks that it contains only
  lowercase letters, numbers, or hyphens.
- It gets the Supabase client and looks up the row whose `slug` matches the
  ID. `maybeSingle()` means the result should be one record or no record.
- If no record exists, the page displays an error instead of pretending it
  loaded successfully.
- On success, it fills the title and metadata text, renders the details, and
  sets the return link.
- It gives the model an accessible text description and its category.
- Animation settings are added only when provided by the database.
- `viewer.src` is set to the model's file path. This is the instruction that
  makes the model-viewer component load the corresponding 3D asset.
- If an audio path exists, it sets the audio element's source.
- It renders the hotspots, reveals the viewer, and hides the loading/error
  status.
- If anything fails, `showError` displays a message.
- The final `loadArtifact()` call starts this work.

### `viewer.js` — make the 3D viewer controls interactive

Open [viewer.js](./viewer.js). This file does not look up the artifact record;
it responds to viewer and button events after the page is set up.

#### Lines 1–5: find the model and controls

The script saves references to the 3D viewer, fullscreen and animation
buttons, loading message, and AR button.

#### Lines 8–16: AR button and animation

When the AR button is clicked, the script checks whether the model has an
animation. If it does, it starts playback and updates the animation button's
label and `aria-pressed` state. Whether AR itself is available depends on the
device and browser support in the 3D viewer component.

#### Lines 19–48: hotspot clicks and optional audio

- One click listener on the viewer handles clicks on any hotspot inside it.
- `closest('.model-hotspot')` finds the hotspot even if the click landed on
  one of its child elements.
- The script closes all hotspot labels, then opens or closes the clicked
  marker and updates `aria-expanded`.
- When an opened hotspot has an audio ID, the audio restarts and plays.

The key visual change is adding or removing `is-expanded`. In `viewer.css`,
`.model-hotspot.is-expanded .hotspot-label` changes the label from hidden to
visible.

#### Lines 51–74: respond when the model loads

`handleViewerLoad()` hides the loading message. If the item is a Value, it
checks whether the model has animations and enables, disables, or labels the
animation button accordingly. It runs when the component reports a load, when
artifact configuration is applied, or immediately if the model already
loaded.

#### Lines 76–86: show a model-loading error

If the model fails to load, the loading message becomes an error message and
the animation control is disabled or marked unavailable.

#### Lines 88–98: play/pause animation

The animation button's `aria-pressed` value records whether it is playing.
Clicking the button calls the model's `play()` or `pause()` method and updates
the state and button text.

#### Lines 100–end: toggle fullscreen

The fullscreen button asks the browser to make the viewer's parent fill the
screen. A second click exits fullscreen. If the browser rejects the request,
the error is logged rather than silently ignored.

### `artifact-redirect.js` — keep older item links working

Open [artifact-redirect.js](./artifact-redirect.js).

- It reads the old page's filename from the address bar and decodes it.
- It removes `.html` and a recognized province prefix to get the item slug.
- It checks the slug's allowed characters.
- It builds the shared viewer URL, adds the slug as the `id` query value,
  then redirects the browser.

This script does not render a card or model; it sends an older link to the
shared viewer page.

### `supabase-client.js` and `supabase-config.js` — connect to the catalog

Open [supabase-client.js](./supabase-client.js) and
[supabase-config.js](./supabase-config.js).

- The config file exports the Supabase project URL and browser-safe
  publishable/anonymous key. Do not put a service-role or other secret key in
  browser code.
- `getSupabaseClient()` checks that the settings are present.
- It imports the Supabase JavaScript library when first needed, creates a
  client, and saves the pending connection so later calls can reuse it.
- If creating the client fails, it clears the failed attempt and reports the
  error to the caller.

These files enable data loading, but do not decide how cards or text look.

## CSS: how each stylesheet shapes the visual output

Each HTML page links to a stylesheet in its `<head>`. The CSS selectors below
match class names or IDs in that page's HTML or in elements created by
JavaScript.

### Shared visual foundation

The home, map, about, and archive stylesheets each define similar shared
rules for the header and navigation. The viewer has a different full-screen
layout.

#### `:root` color variables — at the top of each stylesheet

For example, `--text-main` and `--accent` are reusable color names. A
declaration such as `color: var(--accent)` uses the value stored in the
variable. Changing a variable can update several related elements together.

#### `*`, `html`, and `body` — reset and page defaults

- `*` selects every element. `box-sizing: border-box` makes declared widths
  include padding and borders; zeroing margin and padding removes browser
  default spacing.
- `html { min-width: 320px; }` avoids squeezing the layout below a very narrow
  phone width.
- `body` sets the default font, text color, minimum height, and background.
  `radial-gradient(...)` or `linear-gradient(...)` paints a background
  without needing a background image.

#### `.site-header`, `.team`, `.team-mark`, `.main-nav`

In [home.css](./home.css), [about.css](./about.css),
[map.css](./map.css), and [archive.css](./archive.css):

- `.site-header` uses Flexbox to put the logo/team on one side and navigation
  on the other. `align-items: center` lines them up; `justify-content:
  space-between` spreads them apart.
- `.team` and `.main-nav` are also flex rows. `gap` controls the space between
  their children.
- `.team-mark` sets the logo's dimensions and circular border.
- `.main-nav a` styles links; `:hover` changes appearance over a mouse,
  `:focus-visible` makes keyboard focus visible, and `.active` marks the
  current page.
- The header `@media` rules reduce padding, gaps, or text size on smaller
  screens. They keep the navigation from taking more room than the phone
  layout allows.

The same shared rules appear in multiple files because each page loads its
own stylesheet; a page does not automatically load the other pages' CSS.

### `home.css` — landing page

Open [home.css](./home.css).

- **Lines 1–22:** define shared colors, reset default spacing, and set the
  page background, text color, and font.
- **Lines 24–65:** arrange and style the header, logo, and navigation.
- **Lines 68–80:** shrink the header and navigation at tablet and phone
  widths; the team name is hidden on small screens to save room.
- **Lines 83–89:** give the home page its background and let the main region
  fill the space under the header.
- **Lines 91–97:** `.hero-content` uses a two-column CSS Grid. One column is
  for the title and text; the other is for the map image. `align-items:
  center` vertically aligns them.
- **Lines 98–115:** set the title, tagline, and description sizes, colors,
  spacing, and readable line heights. `clamp(min, preferred, max)` lets
  text size adjust with the screen while staying within limits.
- **Lines 116–134:** make the Explore link look like a rounded button and
  change its background on hover or keyboard focus.
- **Lines 135–143:** size the map image, keep its proportions with
  `object-fit: contain`, and add a drop shadow.
- **Lines 145–end:** at tablet width, tighten the two columns; at phone width,
  stack text and map in one column and reduce text/image sizes.

The HTML contains the words and map image. These rules arrange and decorate
them; the Explore link works because its HTML `href` points to `map.html`.

### `map.css` — province map

Open [map.css](./map.css).

- **Lines 1–99:** define the page's colors, reset, and shared navigation.
- **Lines 101–146:** center the map page, style its heading, and draw a
  bordered, rounded frame around the map area.
- **Lines 149–156:** `.map-frame` creates a square coordinate area. Its
  `position: relative` makes it the positioning reference for the province
  links.
- **Lines 158–187:** each `.province-link` is absolutely positioned over the
  frame. The link's image fills its link box. Hover and keyboard focus raise
  the layer and scale the image slightly with a soft shadow.
- **Lines 189–223:** each province class gives that image link a percentage
  `top`, `left`, and `width`. The percentages place and size the labeled
  province images over the underlying region image at different frame sizes.
- **Lines 225–249:** style the hint and footer. `.visually-hidden` keeps a
  descriptive heading available to assistive technology while not showing
  it visually.
- **Lines 251–end:** reduce page/frame padding on narrow screens. The
  reduced-motion rule makes the image transition nearly instantaneous for
  visitors who request less motion in their device settings.

The province links and their image files are in `map.html`. The CSS positions
them; the links' `href` values take visitors to the corresponding archives.

### `about.css` — team page

Open [about.css](./about.css).

- **Lines 1–80:** define colors, browser reset, background, and shared header
  styles.
- **Lines 82–93:** establish the About page area and center its heading.
- **Lines 95–103:** `.team-grid` is a three-column CSS Grid. `minmax(0, 1fr)`
  gives each column an equal share while allowing it to shrink without
  overflowing.
- **Lines 105–116:** `.team-card` is a vertically arranged Flexbox card with
  padding, border, rounded corners, and centered text.
- **Lines 118–130:** style each role, member heading, circular image area, and
  member name.
- **Lines 132–end:** switch the team grid to one column on narrow screens,
  reduce card padding, and shrink the circular image area.

The actual names and role text come from `about.html`. In the current HTML,
the member-image areas are empty `div` placeholders, so CSS makes them
circular but does not supply portrait pictures.

### `archive.css` — archive page and cards

Open [archive.css](./archive.css).

- **Lines 1–78:** set colors, reset spacing, and style the shared header and
  navigation.
- **Lines 80–149:** style the archive page background, centered
  `.container`, archive heading, and navigation link.
- **Lines 151–178:** style the collection section, its heading, and
  introductory text.
- **Lines 180–207:** lay out the up/down scroll buttons and give keyboard
  users a visible focus outline.
- **Lines 214–245:** display the category tabs in a row. The
  `[aria-selected="true"]` selector gives the selected tab its accent
  underline and text color. This matches the state that `archive.js`
  updates.
- **Lines 247–280:** arrange letter buttons. The `[aria-pressed="true"]`
  selector highlights the chosen filter; `:disabled` makes letters with no
  matching items look unavailable.
- **Lines 282–299:** place the panel heading and item count at opposite ends.
- **Lines 302–318:** make `.archive-items` a one-column grid with a maximum
  height and vertical scrolling. `.archive-item[hidden] { display: none; }`
  ensures a card hidden by JavaScript is not displayed.
- **Lines 320–330:** style the optional empty-list message.
- **Lines 332–364:** make each archive item a bordered flex card. Hovering
  lifts it slightly and adds a shadow; the link retains the card's text color
  and gets a focus outline for keyboard users.
- **Lines 366–409:** style the colored card header, title, subtitle,
  description, and province/type metadata.
- **Lines 411–435:** style the “View Item” call-to-action and change its
  gradient on hover or keyboard focus.
- **Lines 437–end:** style the footer and reduce section spacing for phone
  screens.

This stylesheet is responsible for the archive's appearance, not its item
content. The card's text and category come from the saved HTML fallback or
from the records inserted by `archive.js`.

### `viewer.css` — artifact information and 3D model screen

Open [viewer.css](./viewer.css).

- **Lines 1–29:** define viewer colors and reset spacing. The body is a
  full-height flex row with scrolling hidden at the page level.
- **Lines 32–70:** make `.info-sidebar` the left information column. It has a
  fixed relative width, its own vertical scrolling, a right border, and a
  light panel background. The following rules style the return link, title,
  metadata, and links.
- **Lines 72–112:** set text spacing and line height for details and the
  instruction box.
- **Lines 114–120:** `.viewer-container` is the flexible space for the model
  and overlay controls. `position: relative` lets those controls be placed
  inside it.
- **Lines 122–135:** `#artifact-viewer` fills its container. The custom
  properties set the 3D component's poster and progress bar colors. The
  `[hidden]` rule prevents the viewer from taking up space before the
  artifact data is ready.
- **Lines 138–192:** place and style the hotspot button, number circle, and
  label. The label is normally `display: none`; the
  `.is-expanded` selector displays it after JavaScript opens that hotspot.
- **Lines 194–222:** give the AR control an overlay position and a hover
  appearance. Focus outlines keep keyboard navigation visible.
- **Lines 224–240:** place the loading text over the viewer and hide it once
  the model loads.
- **Lines 242–297:** place and style the fullscreen and animation buttons,
  including hover, disabled, and keyboard-focus states.
- **Lines 299–end:** on smaller screens, stack the information panel and
  viewer vertically instead of side by side. At very narrow widths, give
  the model a little more height than the text panel.

The CSS sets the model viewer's size and the surrounding layout. The
`<model-viewer>` component loads and draws the actual 3D model from the source
URL set by `artifact-page.js`.

## Three concrete examples of code becoming a visual change

### 1. A database row becomes an archive card

`archive.js` reads a row, creates an `<a>` and its child elements, gives them
classes such as `archive-item` and `archive-item-header`, and appends them
to `.archive-items`. `archive.css` matches those classes and supplies the
border, background, spacing, text sizes, and hover effect. The browser
displays the resulting styled card.

### 2. Selecting a letter filters the list

The filter click handler in `archive.js` sets `hidden` on cards whose names
do not begin with the selected letter and updates `aria-pressed` on the
buttons. CSS hides `[hidden]` cards and highlights the button whose
`aria-pressed` value is true. The visible result is a shorter list and a
highlighted filter.

### 3. Opening a hotspot reveals a label

`artifact-page.js` creates a hotspot button and label. `viewer.js` adds the
`is-expanded` class when the visitor clicks the marker. `viewer.css` changes
the label from `display: none` to `display: inline-block` for that class.
That is why the explanation appears beside the numbered point.

## A short explanation you can use in a capstone presentation

> “The HTML defines the page areas and controls. CSS styles those elements
> and changes the layout for different screen sizes. JavaScript loads item
> data from Supabase, fills the page, and responds to clicks. When JavaScript
> changes an element's text, hidden state, or class, the browser updates the
> screen using the CSS rules. The 3D viewer component loads the model file
> and displays it in the viewer area.”

## A practical way to study

1. Start with one visible feature, such as an archive card.
2. Find its HTML container in a province archive page.
3. Find the JavaScript that creates or updates it.
4. Find the CSS selector for its class and see which visual properties it
   sets.
5. Change one harmless visual property in a local copy, reload the page, and
   observe what changed.

You are not expected to know every CSS property or JavaScript method by
memory. Being able to trace one example from page structure, to behavior, to
visual style is a strong way to demonstrate that you understand how the
project works.
