const http = require('http');
const fs = require('fs');
const path = require('path');

// Cargar variables de entorno desde .env si existe
const envPath = path.join(__dirname, '.env');
if (fs.existsSync(envPath)) {
  try {
    const envContent = fs.readFileSync(envPath, 'utf8');
    for (const line of envContent.split(/\r?\n/)) {
      const trimmed = line.trim();
      if (trimmed && !trimmed.startsWith('#')) {
        const idx = trimmed.indexOf('=');
        if (idx !== -1) {
          const key = trimmed.slice(0, idx).trim();
          const val = trimmed.slice(idx + 1).trim().replace(/^['"]|['"]$/g, '');
          if (!process.env[key]) {
            process.env[key] = val;
          }
        }
      }
    }
  } catch (e) {
    console.warn('[Server] Error leyendo .env:', e.message);
  }
}

const PORT = process.env.PORT || 4000;
const RESEND_API_KEY = process.env.RESEND_API_KEY || '';
const DEFAULT_SENDER = 'Quivo Soporte <noreply@thequivoapp.com>';

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff2': 'font/woff2',
};

const server = http.createServer(async (req, res) => {
  // CORS Headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const parsedUrl = new URL(req.url, `http://localhost:${PORT}`);
  const pathname = parsedUrl.pathname;

  // Endpoint de envío de correo vía Resend
  if (req.method === 'POST' && pathname === '/api/send-email') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', async () => {
      try {
        const payload = JSON.parse(body || '{}');
        const toEmail = payload.to;
        const subject = payload.subject;
        const html = payload.html;

        if (!toEmail || !subject || !html) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Faltan campos requeridos: to, subject, html' }));
          return;
        }

        console.log(`[Resend Proxy] Enviando respuesta a: ${toEmail} | Asunto: ${subject}`);

        const resendPayload = {
          from: payload.from || DEFAULT_SENDER,
          to: Array.isArray(toEmail) ? toEmail : [toEmail.trim()],
          subject: subject,
          html: html,
        };

        const resendRes = await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${RESEND_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(resendPayload),
        });

        const resendData = await resendRes.text();
        console.log(`[Resend Proxy] Resend Status: ${resendRes.status} | Data: ${resendData}`);

        res.writeHead(resendRes.status, { 'Content-Type': 'application/json' });
        res.end(resendData);
      } catch (err) {
        console.error('[Resend Proxy] Error:', err);
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // Healthcheck endpoint
  if (pathname === '/api/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', time: new Date().toISOString() }));
    return;
  }

  // Servir archivos estáticos
  let filePath = path.join(__dirname, pathname === '/' ? 'index.html' : pathname);
  
  // Seguridad: evitar path traversal
  if (!filePath.startsWith(__dirname)) {
    res.writeHead(403, { 'Content-Type': 'text/plain' });
    res.end('Acceso Prohibido');
    return;
  }

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      // Fallback a index.html para SPA
      filePath = path.join(__dirname, 'index.html');
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    fs.readFile(filePath, (readErr, content) => {
      if (readErr) {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end('Error interno al leer archivo');
        return;
      }
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content);
    });
  });
});

server.listen(PORT, () => {
  console.log('====================================================');
  console.log('  QUIVO SUPPORT TICKET READER & DASHBOARD');
  console.log('====================================================');
  console.log(`  🚀 Servidor local iniciado en: http://localhost:${PORT}`);
  console.log(`  📧 Proxy Resend activo en:     http://localhost:${PORT}/api/send-email`);
  console.log('  ⚡ Conectado a Firestore (zentai-9b38a)');
  console.log('====================================================\n');
});
