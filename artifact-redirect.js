const filename = decodeURIComponent(window.location.pathname.split('/').pop() || '');
const slug = filename
  .replace(/\.html$/i, '')
  .replace(/^(abra|apayao|benguet|ifugao|kalinga|mountain-province)-/, '');

if (/^[a-z0-9-]+$/.test(slug)) {
  const url = new URL('artifact.html', window.location.href);
  url.searchParams.set('id', slug);
  window.location.replace(url);
}
