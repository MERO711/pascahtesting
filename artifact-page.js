import { getSupabaseClient } from './supabase-client.js';

const nameElement = document.getElementById('artifact-name');
const metaElement = document.getElementById('artifact-meta');
const descriptionElement = document.getElementById('artifact-description');
const statusElement = document.getElementById('artifact-status');
const backLink = document.getElementById('archive-back-link');
const viewer = document.getElementById('artifact-viewer');
const audio = document.getElementById('artifact-audio');

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
      .select('slug, name, province, category, subtitle, description, model_path, audio_path, archive_path')
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
    backLink.href = artifact.archive_path || 'map.html';
    viewer.alt = `Three-dimensional model of ${artifact.name}`;
    viewer.src = new URL(artifact.model_path, document.baseURI).href;
    viewer.hidden = false;

    if (artifact.audio_path) {
      audio.src = new URL(artifact.audio_path, document.baseURI).href;
      audio.setAttribute('aria-label', `${artifact.name} audio`);
      audio.hidden = false;
    }

    statusElement.hidden = true;
  } catch (error) {
    showError(
      'Unable to load this artifact. Check the Supabase configuration and database setup, then try again.',
      error,
    );
  }
}

loadArtifact();
