/*
 * 3D ARTIFACT VIEWER LOGIC: viewer.js
 * Used by artifact pages that contain a <model-viewer>. Controls loading,
 * hotspots, animation playback, AR playback, and fullscreen mode.
 * Selector or element-ID changes here require matching updates in the HTML.
 */
const viewer = document.getElementById('artifact-viewer');
const fullscreenBtn = document.getElementById('fullscreen-btn');
const loadingMessage = viewer.querySelector('.model-loading');
const animationBtn = document.getElementById('animation-btn');
const arButton = viewer.querySelector('.ar-button');

// Start an available animation when the viewer's AR button is used.
arButton?.addEventListener('click', () => {
  if (viewer.availableAnimations.length > 0) {
    viewer.play();
    if (animationBtn) {
      animationBtn.setAttribute('aria-pressed', 'true');
      animationBtn.textContent = 'Pause animation';
    }
  }
});

// Keep model callouts mutually exclusive and expose their state to assistive tech.
viewer.querySelectorAll('.model-hotspot').forEach((hotspot) => {
  hotspot.setAttribute('aria-expanded', 'false');
  hotspot.addEventListener('click', () => {
    const isExpanded = !hotspot.classList.contains('is-expanded');
    viewer.querySelectorAll('.model-hotspot').forEach((otherHotspot) => {
      otherHotspot.classList.remove('is-expanded');
      otherHotspot.setAttribute('aria-expanded', 'false');
    });

    hotspot.classList.toggle('is-expanded', isExpanded);
    hotspot.setAttribute('aria-expanded', String(isExpanded));
  });
});

// Hide the loading message and configure animation controls once the model is ready.
function handleViewerLoad() {
  loadingMessage.hidden = true;
  if (animationBtn) {
    const hasAnimation = viewer.availableAnimations.length > 0;
    animationBtn.disabled = !hasAnimation;
    animationBtn.textContent = hasAnimation ? 'Pause animation' : 'No animation available';
    animationBtn.setAttribute('aria-pressed', String(hasAnimation));
  }
}

// The model may finish loading before or after this script runs.
viewer.addEventListener('load', handleViewerLoad);
if (viewer.loaded) {
  handleViewerLoad();
}

// Show an explicit error state instead of leaving the loading message indefinitely.
viewer.addEventListener('error', () => {
  loadingMessage.textContent = 'The 3D artifact could not be loaded.';
  if (animationBtn) {
    animationBtn.disabled = true;
    animationBtn.textContent = 'Animation unavailable';
  }
});

// Toggle playback only when this model includes an animation.
animationBtn?.addEventListener('click', () => {
  const isPlaying = animationBtn.getAttribute('aria-pressed') === 'true';
  if (isPlaying) {
    viewer.pause();
  } else {
    viewer.play();
  }
  animationBtn.setAttribute('aria-pressed', String(!isPlaying));
  animationBtn.textContent = isPlaying ? 'Play animation' : 'Pause animation';
});

// Use the viewer container so the sidebar and model enter fullscreen together.
fullscreenBtn.addEventListener('click', async () => {
  try {
    if (!document.fullscreenElement) {
      await viewer.parentElement.requestFullscreen();
    } else {
      await document.exitFullscreen();
    }
  } catch (error) {
    console.error('Unable to toggle fullscreen mode:', error);
  }
});
