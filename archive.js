/*
 * ARCHIVE PAGE LOGIC: archive.js
 * Used by every province archive page. This script creates alphabet filters,
 * opens Artifacts/Values tabs, updates item counts, and scrolls card lists.
 * Editing selectors in archive.css must match the class names used below.
 */
// Build alphabet filters and item counts for each category panel.
const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
const tabs = Array.from(document.querySelectorAll('[role="tab"]'));
const panels = Array.from(document.querySelectorAll('.archive-panel'));

panels.forEach((panel) => {
  const items = Array.from(panel.querySelectorAll('.archive-item'));
  const alphabetBar = panel.querySelector('.alphabet-bar');
  const count = panel.querySelector('.item-count');
  const lettersWithItems = new Set(
    items.map((item) => item.querySelector('h4').textContent.trim().charAt(0).toUpperCase()),
  );
  const filters = ['All', ...letters];

  count.textContent = `(${items.length})`;
  filters.forEach((letter) => {
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'alphabet-button';
    button.textContent = letter;
    button.setAttribute('aria-pressed', String(letter === 'All'));
    button.disabled = letter !== 'All' && !lettersWithItems.has(letter);
    button.addEventListener('click', () => {
      alphabetBar.querySelectorAll('.alphabet-button').forEach((filter) => {
        filter.setAttribute('aria-pressed', String(filter === button));
      });

      items.forEach((item) => {
        const initial = item
          .querySelector('h4')
          .textContent.trim()
          .charAt(0)
          .toUpperCase();
        item.hidden = letter !== 'All' && initial !== letter;
      });

      panel.querySelector('.archive-items').scrollTo({ top: 0, behavior: 'smooth' });
    });
    alphabetBar.append(button);
  });
});

// Keep tab selection and panel visibility in sync.
function selectTab(selectedTab) {
  tabs.forEach((tab) => {
    const selected = tab === selectedTab;
    tab.setAttribute('aria-selected', String(selected));
    tab.tabIndex = selected ? 0 : -1;
    document.getElementById(tab.getAttribute('aria-controls')).hidden = !selected;
  });
}

// Let keyboard users move between tabs with the left and right arrow keys.
tabs.forEach((tab, index) => {
  tab.addEventListener('click', () => selectTab(tab));
  tab.addEventListener('keydown', (event) => {
    if (event.key === 'ArrowRight' || event.key === 'ArrowLeft') {
      event.preventDefault();
      const direction = event.key === 'ArrowRight' ? 1 : -1;
      const nextTab = tabs[(index + direction + tabs.length) % tabs.length];
      selectTab(nextTab);
      nextTab.focus();
    }
  });
});

// Scroll the active category list by most of its visible height.
document.querySelectorAll('[data-scroll]').forEach((button) => {
  button.addEventListener('click', () => {
    const panel = button.closest('.archive-panel');
    const list = panel.querySelector('.archive-items');
    const direction = button.dataset.scroll === 'down' ? 1 : -1;
    list.scrollBy({
      top: direction * list.clientHeight * 0.8,
      behavior: 'smooth',
    });
  });
});
