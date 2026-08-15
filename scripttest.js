// 0. Import Three.js modules
import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

// Setup Variables
const container = document.getElementById('viewer-container');
const canvas = document.getElementById('webgl-canvas');
const fullscreenBtn = document.getElementById('fullscreen-btn');

// 1. Scene, Camera, Renderer Initialization
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x0e0e0e);

const camera = new THREE.PerspectiveCamera(
  45,
  container.clientWidth / container.clientHeight,
  0.1,
  1000
);
camera.position.set(0, 1.5, 4);

const renderer = new THREE.WebGLRenderer({ canvas: canvas, antialias: true });
renderer.setSize(container.clientWidth, container.clientHeight);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.shadowMap.enabled = true;

// 2. Interactive OrbitControls (Rotation & Zooming)
const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.dampingFactor = 0.05;
controls.enableZoom = true;

// 3. Lighting Setup
const ambientLight = new THREE.AmbientLight(0xffffff, 1.5);
scene.add(ambientLight);

const mainLight = new THREE.DirectionalLight(0xfff5ea, 2.0);
mainLight.position.set(5, 5, 5);
scene.add(mainLight);

const fillLight = new THREE.DirectionalLight(0x88bbff, 0.8);
fillLight.position.set(-5, -2, -2);
scene.add(fillLight);

// 4. Load external GLTF model
const loader = new GLTFLoader();

loader.load(
  './placeholder_assets/container_quimbaya_culture/scene.gltf',
  (gltf) => {
    const model = gltf.scene;

    // Center the model's bounding box automatically
    const box = new THREE.Box3().setFromObject(model);
    const center = box.getCenter(new THREE.Vector3());
    const size = box.getSize(new THREE.Vector3());

    model.position.x += (model.position.x - center.x);
    model.position.y += (model.position.y - center.y);
    model.position.z += (model.position.z - center.z);

    // Adjust camera & controls target to look at the center of the loaded object
    const maxDim = Math.max(size.x, size.y, size.z);
    camera.position.set(0, maxDim * 0.5, maxDim * 2.5);
    controls.target.copy(new THREE.Vector3(0, 0, 0));
    controls.update();

    scene.add(model);
  },
  (xhr) => {
    console.log((xhr.loaded / xhr.total * 100) + '% loaded');
  },
  (error) => {
    console.error('An error occurred loading the glTF model:', error);
  }
);

// 5. Responsive Resize Handling
function onWindowResize() {
  const width = container.clientWidth;
  const height = container.clientHeight;

  camera.aspect = width / height;
  camera.updateProjectionMatrix();

  renderer.setSize(width, height);
}
window.addEventListener('resize', onWindowResize);

// 6. Fullscreen Functionality
fullscreenBtn.addEventListener('click', () => {
  if (!document.fullscreenElement) {
    container.requestFullscreen().catch(err => {
      alert(`Error attempting to enable fullscreen mode: ${err.message}`);
    });
  } else {
    document.exitFullscreen();
  }
});

document.addEventListener('fullscreenchange', () => {
  setTimeout(onWindowResize, 100);
});

// 7. Animation Loop
function animate() {
  requestAnimationFrame(animate);
  controls.update();
  renderer.render(scene, camera);
}

animate();