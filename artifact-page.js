import { getSupabaseClient } from './supabase-client.js';

const nameElement = document.getElementById('artifact-name');
const metaElement = document.getElementById('artifact-meta');
const descriptionElement = document.getElementById('artifact-description');
const detailsElement = document.getElementById('artifact-details');
const statusElement = document.getElementById('artifact-status');
const backLink = document.getElementById('archive-back-link');
const viewer = document.getElementById('artifact-viewer');
const audio = document.getElementById('artifact-audio');

function renderDetails(details) {
  if (!Array.isArray(details)) {
    throw new Error('Artifact details are missing or invalid.');
  }

  detailsElement.replaceChildren();
  details.forEach((detail) => {
    if (typeof detail.heading !== 'string' || typeof detail.text !== 'string') {
      throw new Error('An artifact detail is missing its heading or text.');
    }

    const paragraph = document.createElement('p');
    const heading = document.createElement('strong');
    heading.textContent = `${detail.heading}: `;
    paragraph.append(heading, detail.text);
    detailsElement.append(paragraph);
  });
}

function isVector(value) {
  const coordinates = value.trim().split(/\s+/);
  return coordinates.length === 3 && coordinates.every((coordinate) => (
    coordinate !== '' && Number.isFinite(Number(coordinate))
  ));
}

function renderHotspots(hotspots) {
  if (!Array.isArray(hotspots)) {
    throw new Error('Artifact hotspots are missing or invalid.');
  }

  const insertionPoint = viewer.querySelector('.ar-button');
  hotspots.forEach((hotspot, index) => {
    if (
      typeof hotspot.position !== 'string'
      || !isVector(hotspot.position)
      || typeof hotspot.normal !== 'string'
      || !isVector(hotspot.normal)
      || typeof hotspot.label !== 'string'
      || typeof hotspot.description !== 'string'
    ) {
      throw new Error(`Artifact hotspot ${index + 1} is missing required data.`);
    }

    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'model-hotspot';
    button.slot = `hotspot-info-${index + 1}`;
    button.dataset.position = hotspot.position;
    button.dataset.normal = hotspot.normal;
    button.setAttribute('aria-label', hotspot.label || `Artifact detail ${index + 1}`);
    button.setAttribute('aria-expanded', 'false');

    const number = document.createElement('span');
    number.className = 'hotspot-number';
    number.textContent = String(index + 1);
    const label = document.createElement('span');
    label.className = 'hotspot-label';

    if (hotspot.label) {
      const title = document.createElement('strong');
      title.textContent = hotspot.label;
      label.append(title);
    }
    if (hotspot.description) {
      if (hotspot.label) {
        label.append(' — ');
      }
      label.append(hotspot.description);
    }
    if (hotspot.audio === true) {
      button.dataset.audio = audio.id;
    }

    button.append(number, label);
    viewer.insertBefore(button, insertionPoint);
  });
}

function showError(message, error) {
  console.error(message, error);
  nameElement.textContent = 'Artifact unavailable';
  statusElement.textContent = message;
}

async function loadArtifact() {
  const slug = new URLSearchParams(window.location.search).get('id')?.trim();
  if (!slug || !/^[a-z0-9-]+$/.test(slug)) {
    showError('No valid artifact was specified. Return to an archive and choose an item.');
    return;
  }

  try {
    const supabase = await getSupabaseClient();
    const { data: artifact, error } = await supabase
      .from('artifacts')
      .select('slug, name, province, category, subtitle, description, model_path, audio_path, archive_path, details, hotspots, animation_name, autoplay, loop')
      .eq('slug', slug)
      .maybeSingle();

    if (error) {
      throw error;
    }

    if (!artifact) {
      showError('That artifact could not be found. Return to an archive and choose another item.');
      return;
    }

    nameElement.textContent = artifact.name;
    document.title = `${artifact.name} | PASCCAH`;
    metaElement.textContent = `${artifact.subtitle} · ${artifact.province} · ${artifact.category}`;
    descriptionElement.textContent = artifact.description;
    renderDetails(artifact.details);
    backLink.href = artifact.archive_path || 'map.html';
    viewer.alt = `Three-dimensional model of ${artifact.name}`;
    if (artifact.animation_name) {
      viewer.setAttribute('animation-name', artifact.animation_name);
    }
    if (artifact.autoplay) {
      viewer.setAttribute('autoplay', '');
    }
    if (artifact.loop) {
      viewer.setAttribute('loop', '');
    }
    viewer.src = new URL(artifact.model_path, document.baseURI).href;

    if (artifact.audio_path) {
      audio.src = new URL(artifact.audio_path, document.baseURI).href;
      audio.setAttribute('aria-label', `${artifact.name} audio`);
      audio.hidden = false;
    }

    renderHotspots(artifact.hotspots);
    viewer.hidden = false;
    statusElement.hidden = true;
  } catch (error) {
    showError(
      'Unable to load this artifact. Check the Supabase configuration and database setup, then try again.',
      error,
    );
  }
}

loadArtifact();
