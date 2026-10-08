# 🎫 Quivo Support Desk — Lector de Tickets Local

Portal web local diseñado para el equipo técnico y de soporte de **Quivo Financial AI**, con el fin de leer, gestionar y brindar respuesta en tiempo real a los tickets enviados desde la aplicación móvil.

---

## 🚀 Características Principales

- **Conexión en Tiempo Real con Firebase Firestore**: Lee automáticamente los tickets de la colección `support_tickets` del proyecto `zentai-9b38a` mediante `onSnapshot`.
- **Métricas y KPIs en Vivo**:
  - Total de tickets recibidos.
  - Tickets abiertos pendientes de atención.
  - Tickets en proceso de investigación técnica.
  - Tickets resueltos y tasa de resolución porcentual.
- **Buscador y Filtros Avanzados**:
  - Búsqueda instantánea por número `#ticket`, correo de usuario o palabras clave en la descripción.
  - Filtro por estado (*Todos, Abiertos, En Proceso, Resueltos, Cerrados*).
  - Filtro rápido por tipo de problema (💳 Transacciones, 🔐 Login, 🎨 Visual, 🧮 Cálculos, 🔔 Notificaciones, 📋 Otro).
- **Gestor de Estados**:
  - Modifica el estado del ticket directamente en Firestore (*Abierto* ➔ *En Proceso* ➔ *Resuelto* ➔ *Cerrado*).
- **Envío de Respuestas por Correo (Resend Integrado)**:
  - Redacción de respuestas con plantillas rápidas precargadas.
  - Envío automático de correo con la API oficial de Resend desde `Quivo Soporte <noreply@thequivoapp.com>`.
- **Diseño Oficial Quivo**:
  - Paleta de colores oficial según `PALETA_DE_COLORES.md`.
  - Modo Oscuro y Modo Claro alternables con un clic.
  - Tipografía profesional `Plus Jakarta Sans` y fuente monoespaciada para IDs.
- **Simulador de Tickets**:
  - Botón integrado para generar tickets de prueba directamente en Firestore y verificar el flujo de extremo a extremo.

---

## 💻 Cómo Iniciar la Página Local

### Opción 1: Con el script automático (Recomendado en Windows)
Haz doble clic en el archivo:
```text
start_lector.bat
```
Esto iniciará el servidor local y abrirá automáticamente tu navegador en `http://localhost:4000`.

### Opción 2: Mediante la terminal
Abre una terminal en la carpeta `lector` y ejecuta:
```bash
node server.js
```
Luego ingresa a: **[http://localhost:4000](http://localhost:4000)**

### Opción 3: Modo Autónomo (Sin servidor Node)
Puedes abrir directamente el archivo `index.html` con cualquier navegador moderno (doble clic sobre `index.html`).

---

## 🔒 Autenticación de Agentes

Si las reglas de seguridad de Firestore requieren autenticación, haz clic en el botón superior **"Acceso Agente"** e ingresa con tu correo y contraseña registrados en Firebase.
