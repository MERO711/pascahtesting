const viewer = document.getElementById('artifact-viewer');
const fullscreenBtn = document.getElementById('fullscreen-btn');
const loadingMessage = viewer.querySelector('.model-loading');
const animationBtn = document.getElementById('animation-btn');

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
  if (animationBtn) {
    const hasAnimation = viewer.availableAnimations.length > 0;
    animationBtn.disabled = !hasAnimation;
    animationBtn.textContent = hasAnimation ? 'Pause animation' : 'No animation available';
    animationBtn.setAttribute('aria-pressed', String(hasAnimation));
  }
});

viewer.addEventListener('error', () => {
  loadingMessage.textContent = 'The 3D artifact could not be loaded.';
  if (animationBtn) {
    animationBtn.disabled = true;
    animationBtn.textContent = 'Animation unavailable';
  }
});

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
