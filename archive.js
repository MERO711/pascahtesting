import { getSupabaseClient } from './supabase-client.js';

const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
const tabs = Array.from(document.querySelectorAll('[role="tab"]'));
const panels = Array.from(document.querySelectorAll('.archive-panel'));

function createArchiveItem(artifact) {
  const link = document.createElement('a');
  link.className = 'archive-item archive-item-link';
  link.href = `artifact.html?id=${encodeURIComponent(artifact.slug)}`;

  const header = document.createElement('div');
  header.className = 'archive-item-header';
  const name = document.createElement('h4');
  name.textContent = artifact.name;
  const subtitle = document.createElement('p');
  subtitle.textContent = artifact.subtitle;
  header.append(name, subtitle);

  const content = document.createElement('div');
  content.className = 'archive-item-content';
  const description = document.createElement('p');
  description.className = 'archive-item-description';
  description.textContent = artifact.description;

  const metadata = document.createElement('div');
  metadata.className = 'archive-item-meta';
  for (const [label, value] of [
    ['Province:', artifact.province],
    ['Type:', artifact.category],
  ]) {
    const item = document.createElement('span');
    const strong = document.createElement('strong');
    strong.textContent = label;
    item.append(strong, ` ${value}`);
    metadata.append(item);
  }

  const button = document.createElement('span');
  button.className = 'view-button';
  const arrow = document.createElement('span');
  arrow.setAttribute('aria-hidden', 'true');
  arrow.textContent = '→';
  button.append('View Item ', arrow);
  content.append(description, metadata, button);
  link.append(header, content);
  return link;
}

function populatePanels(artifacts) {
  const itemsByCategory = new Map([
    ['Artifact', document.createDocumentFragment()],
    ['Value', document.createDocumentFragment()],
  ]);

  artifacts.forEach((artifact) => {
    const fragment = itemsByCategory.get(artifact.category);
    if (fragment) {
      fragment.append(createArchiveItem(artifact));
    }
  });

  for (const [category, fragment] of itemsByCategory) {
    const panelId = category === 'Value' ? 'values-panel' : 'artifacts-panel';
    document.querySelector(`#${panelId} .archive-items`)?.replaceChildren(fragment);
  }
}

function initializeFilters() {
  panels.forEach((panel) => {
    const items = Array.from(panel.querySelectorAll('.archive-item'));
    const alphabetBar = panel.querySelector('.alphabet-bar');
    const count = panel.querySelector('.item-count');
    const lettersWithItems = new Set(
      items
        .map((item) => item.querySelector('h4')?.textContent.trim().charAt(0).toUpperCase())
        .filter(Boolean),
    );

    count.textContent = `(${items.length})`;
    ['All', ...letters].forEach((letter) => {
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
          const initial = item.querySelector('h4').textContent.trim().charAt(0).toUpperCase();
          item.hidden = letter !== 'All' && initial !== letter;
        });

        panel.querySelector('.archive-items').scrollTo({ top: 0, behavior: 'smooth' });
      });
      alphabetBar.append(button);
    });
  });
}

function selectTab(selectedTab) {
  tabs.forEach((tab) => {
    const selected = tab === selectedTab;
    tab.setAttribute('aria-selected', String(selected));
    tab.tabIndex = selected ? 0 : -1;
    document.getElementById(tab.getAttribute('aria-controls')).hidden = !selected;
  });
}

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

async function loadArchive() {
  const title = document.querySelector('.archive-header h1')?.textContent.trim();
  const province = title?.replace(/\s+Archive$/i, '');

  try {
    if (!province) {
      throw new Error('The archive page is missing its province name.');
    }

    const supabase = await getSupabaseClient();
    const { data, error } = await supabase
      .from('artifacts')
      .select('slug, name, province, category, subtitle, description')
      .eq('province', province)
      .order('name');

    if (error) {
      throw error;
    }

    populatePanels(data);
  } catch (error) {
    console.error('Unable to load archive entries from Supabase:', error);
    const status = document.createElement('p');
    status.className = 'archive-status';
    status.setAttribute('role', 'status');
    status.textContent = 'Could not load the latest archive data. Showing the saved archive entries instead.';
    document.querySelector('.archive-navigation')?.after(status);
  }

  initializeFilters();
}

loadArchive();
