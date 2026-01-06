export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    let path = url.pathname.slice(1); // Remove leading slash
    
    // Serve index.html for root path
    if (path === '' || path === '/') {
      path = 'index.html';
    }
    
    // Get object from R2
    const object = await env.BUCKET.get(path);
    
    if (!object) {
      return new Response('Not Found', { status: 404 });
    }
    
    // Determine content type
    const contentType = object.httpMetadata?.contentType || getContentType(path);
    
    const headers = new Headers();
    headers.set('Content-Type', contentType);
    headers.set('Cache-Control', 'public, max-age=300'); // 5 min cache
    
    // Set Content-Disposition for downloads
    if (object.httpMetadata?.contentDisposition) {
      headers.set('Content-Disposition', object.httpMetadata.contentDisposition);
    }
    
    return new Response(object.body, { headers });
  }
};

function getContentType(path) {
  const ext = path.split('.').pop().toLowerCase();
  const types = {
    'html': 'text/html',
    'css': 'text/css',
    'js': 'application/javascript',
    'json': 'application/json',
    'txt': 'text/plain',
    'md': 'text/markdown',
    'sh': 'text/x-shellscript',
    'lz4': 'application/octet-stream',
  };
  return types[ext] || 'application/octet-stream';
}
