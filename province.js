const provinces = new Map([
  ['abra', 'Abra'],
  ['apayao', 'Apayao'],
  ['benguet', 'Benguet'],
  ['ifugao', 'Ifugao'],
  ['kalinga', 'Kalinga'],
  ['mountain-province', 'Mountain Province'],
]);

const provinceKey = new URLSearchParams(window.location.search).get('province');
const provinceName = provinces.get(provinceKey);
const title = document.getElementById('province-title');
const intro = document.getElementById('province-intro');
const archive = document.getElementById('province-archive');
const notFound = document.getElementById('province-not-found');

if (provinceName) {
  title.textContent = `${provinceName} Archive`;
  intro.textContent = `Explore the stories, values, and objects of ${provinceName}.`;
  document.title = `${provinceName} Archive | PASCAH`;
} else {
  title.textContent = 'Province not found';
  intro.textContent = 'Choose a province to explore its archive.';
  document.title = 'Province Not Found | PASCAH';
  archive.hidden = true;
  notFound.hidden = false;
}
