const viewer = document.getElementById('artifact-viewer');
const fullscreenBtn = document.getElementById('fullscreen-btn');
const loadingMessage = viewer.querySelector('.model-loading');

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

viewer.addEventListener('load', () => {
  loadingMessage.hidden = true;
});

viewer.addEventListener('error', () => {
  loadingMessage.textContent = 'The 3D artifact could not be loaded.';
});

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