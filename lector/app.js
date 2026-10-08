/**
 * QUIVO SUPPORT DESK - CLIENT APPLICATION
 * Real-time Firebase Firestore Ticket Reader & Support Manager
 */

// ==========================================================
// 1. FIREBASE CONFIGURATION & INITIALIZATION
// ==========================================================
const firebaseConfig = {
  apiKey: "AIzaSyDf3pJQ-3Cb34ZkQkRkMtkOgES4o3hOVME",
  authDomain: "zentai-9b38a.firebaseapp.com",
  projectId: "zentai-9b38a",
  storageBucket: "zentai-9b38a.firebasestorage.app",
  messagingSenderId: "164540827567",
  appId: "1:164540827567:web:9a0adb61d01092f886915a",
  measurementId: "G-01JBHFY4KE"
};

let app, db, auth;
let isFirestoreInitialized = false;

try {
  app = firebase.initializeApp(firebaseConfig);
  db = firebase.firestore();
  auth = firebase.auth();
  isFirestoreInitialized = true;
} catch (e) {
  console.error('[Firebase] Error inicializando Firebase:', e);
}

// ==========================================================
// 2. STATE MANAGEMENT
// ==========================================================
const state = {
  tickets: [],
  selectedTicket: null,
  activeStatusFilter: 'all',
  activeCategoryFilter: 'all',
  searchQuery: '',
  currentUser: null,
  unsubscribeFirestore: null,
};

// ==========================================================
// 3. DOM ELEMENTS
// ==========================================================
const elements = {
  connectionBadge: document.getElementById('connectionBadge'),
  liveDot: document.getElementById('liveDot'),
  connectionText: document.getElementById('connectionText'),
  themeToggleBtn: document.getElementById('themeToggleBtn'),
  refreshBtn: document.getElementById('refreshBtn'),
  authModalTrigger: document.getElementById('authModalTrigger'),
  agentProfileLabel: document.getElementById('agentProfileLabel'),

  // KPIs
  kpiTotal: document.getElementById('kpiTotal'),
  kpiOpen: document.getElementById('kpiOpen'),
  kpiInProgress: document.getElementById('kpiInProgress'),
  kpiResolved: document.getElementById('kpiResolved'),
  kpiRate: document.getElementById('kpiRate'),

  // Controls
  searchInput: document.getElementById('searchInput'),
  btnSimulateTicket: document.getElementById('btnSimulateTicket'),
  statusTabs: document.getElementById('statusTabs'),
  categoryChips: document.getElementById('categoryChips'),
  ticketsShowingCount: document.getElementById('ticketsShowingCount'),
  ticketsContainer: document.getElementById('ticketsContainer'),

  // Detail Modal
  ticketDetailModal: document.getElementById('ticketDetailModal'),
  closeDetailModalBtn: document.getElementById('closeDetailModalBtn'),
  btnCancelModal: document.getElementById('btnCancelModal'),
  modalTicketNumber: document.getElementById('modalTicketNumber'),
  modalTicketCategory: document.getElementById('modalTicketCategory'),
  modalStatusGroup: document.getElementById('modalStatusGroup'),
  modalUserEmail: document.getElementById('modalUserEmail'),
  modalUserId: document.getElementById('modalUserId'),
  modalCreatedAt: document.getElementById('modalCreatedAt'),
  modalPlatform: document.getElementById('modalPlatform'),
  modalDescription: document.getElementById('modalDescription'),
  templatePills: document.getElementById('templatePills'),
  emailSubjectInput: document.getElementById('emailSubjectInput'),
  emailBodyInput: document.getElementById('emailBodyInput'),
  btnSendEmailResponse: document.getElementById('btnSendEmailResponse'),

  // Auth Modal
  agentAuthModal: document.getElementById('agentAuthModal'),
  closeAuthModalBtn: document.getElementById('closeAuthModalBtn'),
  agentLoginForm: document.getElementById('agentLoginForm'),
  agentEmailInput: document.getElementById('agentEmailInput'),
  agentPassInput: document.getElementById('agentPassInput'),
  btnAgentRegister: document.getElementById('btnAgentRegister'),
  btnGoogleLogin: document.getElementById('btnGoogleLogin'),
  btnLoadDemoFromModal: document.getElementById('btnLoadDemoFromModal'),
  authCurrentUserBox: document.getElementById('authCurrentUserBox'),
  authCurrentEmail: document.getElementById('authCurrentEmail'),
  btnLogoutAgent: document.getElementById('btnLogoutAgent'),

  // Toast
  toastContainer: document.getElementById('toastContainer'),
};

// ==========================================================
// 4. THEME CONTROLLER
// ==========================================================
function initTheme() {
  const savedTheme = localStorage.getItem('quivo_theme') || 'dark';
  setTheme(savedTheme);

  elements.themeToggleBtn.addEventListener('click', () => {
    const currentTheme = document.documentElement.getAttribute('data-theme') || 'dark';
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    setTheme(newTheme);
  });
}

function setTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem('quivo_theme', theme);
}

// ==========================================================
// 5. TOAST NOTIFICATIONS
// ==========================================================
function showToast(message, type = 'info') {
  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.innerHTML = `
    <span>${type === 'success' ? '✅' : type === 'error' ? '❌' : 'ℹ️'}</span>
    <span>${message}</span>
  `;
  elements.toastContainer.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateY(10px)';
    setTimeout(() => toast.remove(), 300);
  }, 3800);
}

// ==========================================================
// 6. FIRESTORE REAL-TIME LISTENER
// ==========================================================
function startFirestoreListener() {
  if (!isFirestoreInitialized) {
    updateConnectionStatus('error', 'Error en Firebase');
    return;
  }

  updateConnectionStatus('connecting', 'Conectando a Firestore...');

  if (state.unsubscribeFirestore) {
    state.unsubscribeFirestore();
  }

  try {
    const ticketsRef = db.collection('support_tickets');

    state.unsubscribeFirestore = ticketsRef.onSnapshot(
      (snapshot) => {
        const rawTickets = [];
        snapshot.forEach((doc) => {
          const data = doc.data();
          rawTickets.push({
            id: doc.id,
            ticketNumber: data.ticket_number || 0,
            userId: data.user_id || 'N/A',
            userEmail: data.user_email || 'Sin correo',
            issueType: data.issue_type || 'General',
            description: data.description || '',
            status: (data.status || 'open').toLowerCase(),
            createdAt: data.created_at ? data.created_at.toDate() : new Date(),
            metadata: data.metadata || {},
          });
        });

        // Ordenar por ticket_number desc o createdAt desc
        rawTickets.sort((a, b) => {
          if (b.ticketNumber !== a.ticketNumber) {
            return b.ticketNumber - a.ticketNumber;
          }
          return b.createdAt.getTime() - a.createdAt.getTime();
        });

        state.tickets = rawTickets;
        updateConnectionStatus('connected', `🟢 En Vivo (${rawTickets.length} tickets)`);
        renderDashboard();
      },
      (error) => {
        console.warn('[Firestore] Error al escuchar tickets:', error);
        if (error.code === 'permission-denied') {
          updateConnectionStatus('auth-needed', '🔒 Requiere Login de Agente');
          showToast('Permiso denegado por reglas de Firestore. Inicia sesión como agente.', 'error');
        } else {
          updateConnectionStatus('error', '⚠️ Error de Conexión');
          showToast(`Error de Firestore: ${error.message}`, 'error');
        }
      }
    );
  } catch (err) {
    console.error('[Firestore] Excepción al suscribir:', err);
    updateConnectionStatus('error', 'Error inesperado');
  }
}

function updateConnectionStatus(status, text) {
  elements.connectionText.textContent = text;
  elements.connectionBadge.className = 'live-indicator';

  if (status === 'connected') {
    elements.liveDot.style.background = 'var(--emerald)';
    elements.liveDot.style.boxShadow = '0 0 10px var(--emerald)';
  } else if (status === 'demo') {
    elements.liveDot.style.background = 'var(--amber)';
    elements.liveDot.style.boxShadow = '0 0 10px var(--amber)';
  } else if (status === 'connecting') {
    elements.liveDot.style.background = 'var(--cyan)';
    elements.liveDot.style.boxShadow = '0 0 10px var(--cyan)';
  } else if (status === 'auth-needed') {
    elements.liveDot.style.background = 'var(--rose)';
    elements.liveDot.style.boxShadow = '0 0 10px var(--rose)';
  } else {
    elements.liveDot.style.background = 'var(--text-dim)';
    elements.liveDot.style.boxShadow = 'none';
  }
}

// ==========================================================
// 7. FIREBASE AUTH MANAGEMENT
// ==========================================================
function initAuth() {
  if (!auth) return;

  auth.onAuthStateChanged((user) => {
    state.currentUser = user;
    if (user) {
      state.isDemoMode = false;
      elements.agentProfileLabel.textContent = user.email ? user.email.split('@')[0] : 'Agente';
      elements.authCurrentUserBox.style.display = 'block';
      elements.authCurrentEmail.textContent = user.email || 'Usuario Autenticado';
      elements.agentLoginForm.style.display = 'none';
      startFirestoreListener(); // Reintentar conectar con el usuario autenticado
    } else {
      elements.agentProfileLabel.textContent = 'Acceso Agente';
      elements.authCurrentUserBox.style.display = 'none';
      elements.agentLoginForm.style.display = 'flex';
    }
  });

  // Login de agente con correo/contraseña
  elements.agentLoginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = elements.agentEmailInput.value.trim();
    const password = elements.agentPassInput.value;

    const submitBtn = document.getElementById('btnAgentSubmit');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Iniciando...';

    try {
      await auth.signInWithEmailAndPassword(email, password);
      showToast('Sesión iniciada correctamente', 'success');
      closeModal(elements.agentAuthModal);
    } catch (err) {
      console.error('Error al iniciar sesión:', err);
      if (err.code === 'auth/user-not-found' || err.code === 'auth/invalid-credential') {
        showToast('Credenciales no encontradas. Puedes hacer clic en "Registrar Agente" para crear esta cuenta.', 'error');
      } else {
        showToast(`Error de autenticación: ${err.message}`, 'error');
      }
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = 'Iniciar Sesión';
    }
  });

  // Registro de nuevo agente
  elements.btnAgentRegister?.addEventListener('click', async () => {
    const email = elements.agentEmailInput.value.trim();
    const password = elements.agentPassInput.value;

    if (!email || !password) {
      showToast('Ingresa un correo y contraseña para registrar al agente', 'error');
      elements.agentEmailInput.focus();
      return;
    }

    if (password.length < 6) {
      showToast('La contraseña debe tener al menos 6 caracteres', 'error');
      elements.agentPassInput.focus();
      return;
    }

    const regBtn = elements.btnAgentRegister;
    regBtn.disabled = true;
    regBtn.textContent = 'Registrando...';

    try {
      await auth.createUserWithEmailAndPassword(email, password);
      showToast('¡Agente registrado e iniciado con éxito!', 'success');
      closeModal(elements.agentAuthModal);
    } catch (err) {
      console.error('Error al registrar agente:', err);
      showToast(`Error al registrar: ${err.message}`, 'error');
    } finally {
      regBtn.disabled = false;
      regBtn.textContent = 'Registrar Agente';
    }
  });

  // Inicio de sesión con Google
  elements.btnGoogleLogin?.addEventListener('click', async () => {
    try {
      const provider = new firebase.auth.GoogleAuthProvider();
      await auth.signInWithPopup(provider);
      showToast('Sesión iniciada con Google', 'success');
      closeModal(elements.agentAuthModal);
    } catch (err) {
      console.error('Error al iniciar con Google:', err);
      showToast(`Error de Google Auth: ${err.message}`, 'error');
    }
  });

  // Cargar Modo Demostración desde el Modal
  elements.btnLoadDemoFromModal?.addEventListener('click', () => {
    loadDemoTickets();
    closeModal(elements.agentAuthModal);
  });

  elements.btnLogoutAgent.addEventListener('click', async () => {
    await auth.signOut();
    showToast('Sesión cerrada', 'info');
    closeModal(elements.agentAuthModal);
  });
}

// ==========================================================
// 8. DASHBOARD RENDERING & FILTERING
// ==========================================================
function renderDashboard() {
  updateKPICounters();
  renderTicketList();
}

function updateKPICounters() {
  const total = state.tickets.length;
  const openCount = state.tickets.filter(t => t.status === 'open').length;
  const inProgressCount = state.tickets.filter(t => t.status === 'in_progress').length;
  const resolvedCount = state.tickets.filter(t => t.status === 'resolved').length;
  const closedCount = state.tickets.filter(t => t.status === 'closed').length;

  elements.kpiTotal.textContent = total;
  elements.kpiOpen.textContent = openCount;
  elements.kpiInProgress.textContent = inProgressCount;
  elements.kpiResolved.textContent = resolvedCount;

  const rate = total > 0 ? Math.round((resolvedCount / total) * 100) : 0;
  elements.kpiRate.textContent = `Tasa de resolución: ${rate}%`;

  // Tab count badges
  document.getElementById('countAll').textContent = total;
  document.getElementById('countOpen').textContent = openCount;
  document.getElementById('countInProgress').textContent = inProgressCount;
  document.getElementById('countResolved').textContent = resolvedCount;
  document.getElementById('countClosed').textContent = closedCount;
}

function getFilteredTickets() {
  const query = state.searchQuery.toLowerCase().trim();
  const statusFilter = state.activeStatusFilter;
  const categoryFilter = state.activeCategoryFilter;

  return state.tickets.filter(ticket => {
    // Status filter
    if (statusFilter !== 'all' && ticket.status !== statusFilter) {
      return false;
    }

    // Category filter
    if (categoryFilter !== 'all' && ticket.issueType.toLowerCase() !== categoryFilter.toLowerCase()) {
      return false;
    }

    // Search query filter
    if (query) {
      const matchNumber = `#${ticket.ticketNumber}`.toLowerCase().includes(query) || ticket.ticketNumber.toString().includes(query);
      const matchEmail = ticket.userEmail.toLowerCase().includes(query);
      const matchUserId = ticket.userId.toLowerCase().includes(query);
      const matchDesc = ticket.description.toLowerCase().includes(query);
      const matchCategory = ticket.issueType.toLowerCase().includes(query);

      return matchNumber || matchEmail || matchUserId || matchDesc || matchCategory;
    }

    return true;
  });
}

function renderTicketList() {
  const filtered = getFilteredTickets();
  elements.ticketsShowingCount.textContent = `Mostrando ${filtered.length} de ${state.tickets.length} tickets`;
  elements.ticketsContainer.innerHTML = '';

  if (filtered.length === 0) {
    if (!state.currentUser && state.tickets.length === 0) {
      elements.ticketsContainer.innerHTML = `
        <div class="empty-state" style="border: 2px dashed var(--border-focus); background: rgba(79, 70, 229, 0.05); padding: 40px 24px; border-radius: var(--radius-lg);">
          <div class="empty-state-icon" style="font-size: 42px; margin-bottom: 12px;">🔒</div>
          <h3 style="font-size: 20px; color: var(--text-primary); margin-bottom: 8px;">Inicio de Sesión Requerido por Firebase</h3>
          <p style="max-width: 520px; margin: 0 auto 20px; color: var(--text-muted); font-size: 14px; line-height: 1.6;">
            Para ver los tickets en tiempo real de Firestore, debes iniciar sesión con una cuenta de agente/usuario de QUIVO. También puedes explorar el panel de inmediato con tickets de demostración.
          </p>
          <div style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">
            <button class="btn btn-primary" onclick="openModal(elements.agentAuthModal)">
              <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
              </svg>
              <span>Iniciar Sesión / Registrarse</span>
            </button>
            <button class="btn btn-secondary" onclick="loadDemoTickets()" style="background: rgba(245, 158, 11, 0.15); color: var(--amber); border-color: var(--amber-border);">
              <span>🧪 Ver con Tickets de Demostración</span>
            </button>
          </div>
        </div>
      `;
      return;
    }

    elements.ticketsContainer.innerHTML = `
      <div class="empty-state">
        <div class="empty-state-icon">📂</div>
        <h3>No se encontraron tickets</h3>
        <p>No hay tickets que coincidan con los filtros seleccionados o aún no se han subido registros a la base de datos.</p>
        <div style="display: flex; gap: 10px; justify-content: center; margin-top: 16px;">
          <button class="btn btn-primary" onclick="simulateNewTicket()">
            <span>Crear un Ticket de Prueba</span>
          </button>
          <button class="btn btn-secondary" onclick="loadDemoTickets()">
            <span>Cargar Modo Demostración</span>
          </button>
        </div>
      </div>
    `;
    return;
  }

  filtered.forEach(ticket => {
    const card = document.createElement('article');
    card.className = 'ticket-card';
    card.setAttribute('tabindex', '0');

    const formattedDate = formatRelativeTime(ticket.createdAt);
    const platform = ticket.metadata?.platform || 'app';
    const categoryIcon = getCategoryIcon(ticket.issueType);

    card.innerHTML = `
      <div class="ticket-card-header">
        <div class="ticket-number-tag">
          <span class="ticket-id">#${ticket.ticketNumber}</span>
          <span class="ticket-category-tag">${categoryIcon} ${escapeHtml(ticket.issueType)}</span>
        </div>
        <span class="ticket-status-badge status-${ticket.status}">
          ${getStatusLabel(ticket.status)}
        </span>
      </div>

      <div class="ticket-description">
        ${escapeHtml(ticket.description)}
      </div>

      <div class="ticket-card-footer">
        <div class="ticket-user-meta">
          <span class="ticket-email">
            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"/>
            </svg>
            ${escapeHtml(ticket.userEmail)}
          </span>
          <span class="ticket-platform-badge">${escapeHtml(platform)}</span>
        </div>
        <div class="ticket-time">
          <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
          </svg>
          ${formattedDate}
        </div>
      </div>
    `;

    card.addEventListener('click', () => openTicketDetail(ticket));
    card.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        openTicketDetail(ticket);
      }
    });

    elements.ticketsContainer.appendChild(card);
  });
}

// ==========================================================
// 9. TICKET DETAIL MODAL & SUPPORT ACTIONS
// ==========================================================
function openTicketDetail(ticket) {
  state.selectedTicket = ticket;

  elements.modalTicketNumber.textContent = `#${ticket.ticketNumber}`;
  elements.modalTicketCategory.textContent = `${getCategoryIcon(ticket.issueType)} ${ticket.issueType}`;
  elements.modalUserEmail.textContent = ticket.userEmail;
  elements.modalUserId.textContent = ticket.userId;
  elements.modalCreatedAt.textContent = ticket.createdAt.toLocaleString('es-ES', {
    dateStyle: 'full',
    timeStyle: 'medium'
  });
  
  const platform = ticket.metadata?.platform || 'N/A';
  const version = ticket.metadata?.app_version || '1.1';
  elements.modalPlatform.textContent = `${platform} (v${version})`;
  elements.modalDescription.textContent = ticket.description;

  // Actualizar botones de estado
  updateStatusButtonsUI(ticket.status);

  // Precargar asunto del correo
  elements.emailSubjectInput.value = `[Quivo Soporte] Actualización sobre tu Ticket #${ticket.ticketNumber}: ${ticket.issueType}`;
  elements.emailBodyInput.value = '';

  openModal(elements.ticketDetailModal);
}

function updateStatusButtonsUI(currentStatus) {
  const buttons = elements.modalStatusGroup.querySelectorAll('.btn-status-option');
  buttons.forEach(btn => {
    const status = btn.getAttribute('data-status');
    if (status === currentStatus) {
      btn.classList.add('active');
    } else {
      btn.classList.remove('active');
    }
  });
}

// Modificar estado en Firestore
async function updateTicketStatus(newStatus) {
  if (!state.selectedTicket) return;

  const ticketId = state.selectedTicket.id;
  const oldStatus = state.selectedTicket.status;

  if (oldStatus === newStatus) return;

  try {
    showToast(`Actualizando estado a "${getStatusLabel(newStatus)}"...`, 'info');

    if (db) {
      await db.collection('support_tickets').doc(ticketId).update({
        status: newStatus,
        updated_at: firebase.firestore.FieldValue.serverTimestamp()
      });
    }

    state.selectedTicket.status = newStatus;
    updateStatusButtonsUI(newStatus);
    showToast(`Ticket #${state.selectedTicket.ticketNumber} actualizado a ${getStatusLabel(newStatus)}`, 'success');

    // Auto-generar plantilla según el cambio de estado si el textarea está vacío
    if (!elements.emailBodyInput.value) {
      if (newStatus === 'resolved') {
        applyTemplate('solved');
      } else if (newStatus === 'in_progress') {
        applyTemplate('investigating');
      } else if (newStatus === 'closed') {
        applyTemplate('closed');
      }
    }
  } catch (err) {
    console.error('Error al actualizar estado en Firestore:', err);
    showToast(`Error al guardar: ${err.message}`, 'error');
  }
}

// ==========================================================
// 10. EMAIL RESPONSE VIA RESEND
// ==========================================================
const emailTemplates = {
  investigating: (ticket) => 
    `Hola,\n\nHemos recibido tu reporte sobre "${ticket.issueType}". Nuestro equipo técnico ya está investigando lo sucedido para ofrecerte una solución a la brevedad.\n\nTe notificaremos por este mismo medio tan pronto tengamos novedades.\n\nAtentamente,\nEquipo de Soporte de Quivo`,
  
  solved: (ticket) => 
    `Hola,\n\nTe confirmamos que la incidencia reportada en tu Ticket #${ticket.ticketNumber} ("${ticket.issueType}") ha sido resuelta con éxito.\n\nPor favor abre de nuevo la aplicación Quivo y comprueba que todo funcione como esperas. Si continúas experimentando inconvenientes, no dudes en responder a este correo.\n\n¡Gracias por confiar en Quivo!\nAtentamente,\nEquipo de Soporte`,
  
  more_info: (ticket) => 
    `Hola,\n\nPara poder dar seguimiento adecuado a tu Ticket #${ticket.ticketNumber}, ¿podrías detallarnos un poco más lo ocurrido o enviarnos una captura de pantalla del mensaje que aparece en la aplicación?\n\nQuedamos muy atentos a tu respuesta para ayudarte de inmediato.\n\nAtentamente,\nEquipo de Soporte de Quivo`,
  
  closed: (ticket) => 
    `Hola,\n\nTe informamos que tu Ticket de Soporte #${ticket.ticketNumber} ha sido completado y marcado como cerrado.\n\nSi necesitas asistencia adicional en el futuro, siempre puedes crear un nuevo ticket desde la aplicación.\n\nSaludos cordiales,\nEquipo de Soporte de Quivo`
};

function applyTemplate(key) {
  if (!state.selectedTicket) return;
  const templateFn = emailTemplates[key];
  if (templateFn) {
    elements.emailBodyInput.value = templateFn(state.selectedTicket);
  }
}

async function sendSupportEmail() {
  if (!state.selectedTicket) return;

  const toEmail = state.selectedTicket.userEmail;
  const subject = elements.emailSubjectInput.value.trim();
  const textBody = elements.emailBodyInput.value.trim();

  if (!subject) {
    showToast('Por favor escribe un asunto para el correo', 'error');
    elements.emailSubjectInput.focus();
    return;
  }

  if (!textBody) {
    showToast('Por favor redacta el cuerpo de la respuesta', 'error');
    elements.emailBodyInput.focus();
    return;
  }

  // HTML formateado con estilo corporativo de Quivo
  const htmlBody = `
    <div style="font-family: 'Plus Jakarta Sans', Arial, sans-serif; max-width: 600px; margin: 0 auto; background-color: #0C0A1D; color: #E2E8F0; padding: 32px; border-radius: 16px; border: 1px solid #262347;">
      <div style="border-bottom: 2px solid #4F46E5; padding-bottom: 16px; margin-bottom: 24px;">
        <h2 style="color: #FFFFFF; margin: 0; font-size: 22px;">Quivo <span style="color: #A5B4FC; font-size: 14px; font-weight: normal;">• Soporte Técnico</span></h2>
      </div>
      <div style="background-color: #131127; padding: 14px 18px; border-radius: 10px; border: 1px solid #262347; margin-bottom: 20px;">
        <span style="color: #A5B4FC; font-weight: bold; font-size: 13px;">Ticket #${state.selectedTicket.ticketNumber}</span>
        <span style="color: #94A3B8; font-size: 13px;"> | ${state.selectedTicket.issueType}</span>
      </div>
      <div style="font-size: 15px; line-height: 1.6; color: #CBD5E1; white-space: pre-wrap;">${escapeHtml(textBody)}</div>
      <div style="margin-top: 36px; padding-top: 16px; border-top: 1px solid #262347; font-size: 12px; color: #64748B; text-align: center;">
        Este es un mensaje oficial enviado por el equipo de Quivo Financial AI.<br>
        &copy; ${new Date().getFullYear()} Quivo Tech. Todos los derechos reservados.
      </div>
    </div>
  `;

  const sendBtn = elements.btnSendEmailResponse;
  sendBtn.disabled = true;
  sendBtn.innerHTML = `<span>Enviando correo...</span>`;

  try {
    // Petición al endpoint local /api/send-email (servidor proxy en server.js)
    const res = await fetch('/api/send-email', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        to: toEmail,
        subject: subject,
        html: htmlBody,
        from: 'Quivo Soporte <noreply@thequivoapp.com>'
      })
    });

    if (res.ok) {
      showToast(`Respuesta enviada exitosamente a ${toEmail}`, 'success');
      elements.emailBodyInput.value = '';
    } else {
      const errData = await res.json().catch(() => ({}));
      throw new Error(errData.error || `HTTP ${res.status}`);
    }
  } catch (err) {
    console.warn('[Resend] No se pudo enviar por API proxy local:', err);
    // Fallback: Si no está corriendo el server.js o falló la API, ofrecer mailto
    const mailtoUrl = `mailto:${encodeURIComponent(toEmail)}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(textBody)}`;
    window.open(mailtoUrl, '_blank');
    showToast('Abriendo cliente de correo nativo (fallback mailto)', 'info');
  } finally {
    sendBtn.disabled = false;
    sendBtn.innerHTML = `
      <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
      </svg>
      <span>Enviar Respuesta por Correo</span>
    `;
  }
}

// ==========================================================
// 11. TICKET SIMULATOR (DEV / TESTING)
// ==========================================================
async function simulateNewTicket() {
  if (!db) {
    showToast('Firestore no está disponible', 'error');
    return;
  }

  elements.btnSimulateTicket.disabled = true;
  showToast('Generando ticket de prueba en Firestore...', 'info');

  const categories = [
    'Error en transacción',
    'Problema de inicio de sesión',
    'Fallo visual',
    'Error en cálculos',
    'Problema con notificaciones',
    'Otro'
  ];

  const sampleDescriptions = [
    'Al intentar registrar un gasto en la categoría Transporte, la pantalla se quedó en blanco y no guardó el monto.',
    'No recibí el código de verificación por correo al intentar cambiar mi contraseña.',
    'El gráfico de gastos mensuales muestra un total diferente a la suma de la lista de transacciones.',
    'Los badges de ahorro no se desbloquearon a pesar de cumplir con el objetivo mensual fijado.',
    'La aplicación se cierra inesperadamente cuando intento exportar el reporte a formato PDF.',
    'Fallo en la visualización de la barra de presupuesto en el modo oscuro.'
  ];

  const randomCat = categories[Math.floor(Math.random() * categories.length)];
  const randomDesc = sampleDescriptions[Math.floor(Math.random() * sampleDescriptions.length)];
  const randomEmail = `usuario_prueba_${Math.floor(Math.random() * 899 + 100)}@gmail.com`;

  try {
    if (!state.currentUser || state.isDemoMode) {
      const nextNum = (state.tickets.reduce((max, t) => Math.max(max, t.ticketNumber || 0), 1000)) + 1;
      const localTicket = {
        id: `local-${nextNum}`,
        ticketNumber: nextNum,
        userId: `usr_${Math.random().toString(36).substring(2, 8)}`,
        userEmail: randomEmail,
        issueType: randomCat,
        description: randomDesc,
        status: 'open',
        createdAt: new Date(),
        metadata: {
          platform: ['Android (App v1.4.0)', 'iOS (App v1.4.0)', 'Web Dashboard'][Math.floor(Math.random() * 3)],
          app_version: '1.4.0+5'
        }
      };
      state.tickets.unshift(localTicket);
      renderDashboard();
      showToast(`Ticket #${nextNum} generado en memoria local`, 'success');
      return;
    }

    // Obtener siguiente número de ticket con transacción en Firestore
    const counterRef = db.doc('counters/support_tickets');
    const assignedNumber = await db.runTransaction(async (transaction) => {
      const counterSnap = await transaction.get(counterRef);
      let nextNumber = 1;
      if (counterSnap.exists) {
        nextNumber = (counterSnap.data().lastTicketNumber || 0) + 1;
      }
      transaction.set(counterRef, {
        lastTicketNumber: nextNumber,
        updated_at: firebase.firestore.FieldValue.serverTimestamp()
      }, { merge: true });

      const newTicketRef = db.collection('support_tickets').doc();
      transaction.set(newTicketRef, {
        ticket_number: nextNumber,
        user_id: `usr_${Math.random().toString(36).substring(2, 10)}`,
        user_email: randomEmail,
        issue_type: randomCat,
        description: randomDesc,
        status: 'open',
        created_at: firebase.firestore.FieldValue.serverTimestamp(),
        metadata: {
          platform: ['android', 'ios', 'web', 'windows'][Math.floor(Math.random() * 4)],
          app_version: '1.4.0'
        }
      });

      return nextNumber;
    });

    showToast(`Ticket #${assignedNumber} creado con éxito en Firestore`, 'success');
  } catch (err) {
    console.error('Error al simular ticket:', err);
    if (err.code === 'permission-denied') {
      showToast('Permiso denegado en Firestore. Generando ticket localmente...', 'info');
      state.isDemoMode = true;
      const nextNum = (state.tickets.reduce((max, t) => Math.max(max, t.ticketNumber || 0), 1000)) + 1;
      state.tickets.unshift({
        id: `local-${nextNum}`,
        ticketNumber: nextNum,
        userId: `usr_offline`,
        userEmail: randomEmail,
        issueType: randomCat,
        description: randomDesc,
        status: 'open',
        createdAt: new Date(),
        metadata: { platform: 'Android (v1.4.0)', app_version: '1.4.0+5' }
      });
      renderDashboard();
    } else {
      showToast(`No se pudo crear en Firestore: ${err.message}`, 'error');
    }
  } finally {
    elements.btnSimulateTicket.disabled = false;
  }
}

// Cargar conjunto de tickets de demostración sin necesidad de login
function loadDemoTickets() {
  state.isDemoMode = true;
  state.tickets = [
    {
      id: 'demo-1001',
      ticketNumber: 1001,
      issueType: 'Error en transacción',
      description: 'Intenté registrar un gasto recurrente de renta mensual ($450.00) pero la aplicación no guardó la fecha de próximo cobro en el calendario.',
      userEmail: 'carlos.mendoza@gmail.com',
      userId: 'usr_carlos_9921',
      status: 'open',
      createdAt: new Date(Date.now() - 1000 * 60 * 18),
      metadata: {
        platform: 'Android (App v1.4.0)',
        app_version: '1.4.0+5',
        device: 'Samsung Galaxy S23',
        isPremium: true
      }
    },
    {
      id: 'demo-1002',
      ticketNumber: 1002,
      issueType: 'Problema con notificaciones',
      description: 'Ayer no recibí las notificaciones programadas de las 2:00 PM ni de las 7:00 PM para registrar mis gastos de la tarde.',
      userEmail: 'ana.sofia@yahoo.com',
      userId: 'usr_anasofia_431',
      status: 'in_progress',
      createdAt: new Date(Date.now() - 1000 * 60 * 60 * 2),
      metadata: {
        platform: 'iOS (App v1.4.0)',
        app_version: '1.4.0+5',
        device: 'iPhone 15 Pro',
        isPremium: false
      }
    },
    {
      id: 'demo-1003',
      ticketNumber: 1003,
      issueType: 'Error en cálculos',
      description: 'En el módulo What-If, cuando cambio la tasa de interés de la tarjeta de crédito de 28% a 18%, el ahorro proyectado a 12 meses no se recalcula automáticamente hasta que salgo y vuelvo a entrar.',
      userEmail: 'marroquimd@gmail.com',
      userId: 'usr_daniel_001',
      status: 'open',
      createdAt: new Date(Date.now() - 1000 * 60 * 60 * 5),
      metadata: {
        platform: 'Android (App v1.4.0)',
        app_version: '1.4.0+5',
        device: 'Pixel 8 Pro',
        isPremium: true
      }
    },
    {
      id: 'demo-1004',
      ticketNumber: 1004,
      issueType: 'Otro',
      description: '¡Hola! Quisiera saber cómo aprovechar la promoción del 50% de descuento en la suscripción de QUIVO Premium.',
      userEmail: 'valeria.tech@hotmail.com',
      userId: 'usr_valeria_772',
      status: 'resolved',
      createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24),
      metadata: {
        platform: 'Android (App v1.4.0)',
        app_version: '1.4.0+5',
        device: 'Xiaomi 13',
        isPremium: false
      }
    },
    {
      id: 'demo-1005',
      ticketNumber: 1005,
      issueType: 'Fallo visual',
      description: 'El botón de "Añadir Fondos" en el modal de metas de ahorro se solapa ligeramente con la barra inferior en pantallas pequeñas.',
      userEmail: 'roberto_dev@outlook.com',
      userId: 'usr_roberto_105',
      status: 'closed',
      createdAt: new Date(Date.now() - 1000 * 60 * 60 * 48),
      metadata: {
        platform: 'iOS (App v1.4.0)',
        app_version: '1.4.0+5',
        device: 'iPhone SE (3rd Gen)',
        isPremium: true
      }
    }
  ];

  updateConnectionStatus('demo', `🟡 Modo Demostración (${state.tickets.length} tickets)`);
  renderDashboard();
  showToast('Modo demostración cargado con 5 tickets de ejemplo', 'success');
}

// ==========================================================
// 12. UTILITY & HELPER FUNCTIONS
// ==========================================================
function getStatusLabel(status) {
  const map = {
    open: 'Abierto',
    in_progress: 'En Proceso',
    resolved: 'Resuelto',
    closed: 'Cerrado'
  };
  return map[status] || status;
}

function getCategoryIcon(cat) {
  const map = {
    'Error en transacción': '💳',
    'Problema de inicio de sesión': '🔐',
    'Fallo visual': '🎨',
    'Error en cálculos': '🧮',
    'Problema con notificaciones': '🔔',
    'Otro': '📋'
  };
  return map[cat] || '📋';
}

function formatRelativeTime(date) {
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffSec = Math.floor(diffMs / 1000);
  const diffMin = Math.floor(diffSec / 60);
  const diffHour = Math.floor(diffMin / 60);
  const diffDay = Math.floor(diffHour / 24);

  if (diffSec < 60) return 'Hace un momento';
  if (diffMin < 60) return `Hace ${diffMin} min`;
  if (diffHour < 24) return `Hace ${diffHour} h`;
  if (diffDay === 1) return 'Ayer';
  if (diffDay < 7) return `Hace ${diffDay} días`;

  return date.toLocaleDateString('es-ES', { day: '2-digit', month: 'short' });
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function openModal(modal) {
  modal.classList.add('active');
  modal.setAttribute('aria-hidden', 'false');
  document.body.style.overflow = 'hidden';
}

function closeModal(modal) {
  modal.classList.remove('active');
  modal.setAttribute('aria-hidden', 'true');
  document.body.style.overflow = '';
}

// ==========================================================
// 13. EVENT LISTENERS SETUP
// ==========================================================
function initEvents() {
  // Search input
  elements.searchInput.addEventListener('input', (e) => {
    state.searchQuery = e.target.value;
    renderTicketList();
  });

  // Status tabs
  elements.statusTabs.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      elements.statusTabs.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      state.activeStatusFilter = btn.getAttribute('data-status');
      renderTicketList();
    });
  });

  // Category chips
  elements.categoryChips.querySelectorAll('.category-chip').forEach(chip => {
    chip.addEventListener('click', () => {
      elements.categoryChips.querySelectorAll('.category-chip').forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      state.activeCategoryFilter = chip.getAttribute('data-cat');
      renderTicketList();
    });
  });

  // Refresh button
  elements.refreshBtn.addEventListener('click', () => {
    showToast('Sincronizando con Firestore...', 'info');
    startFirestoreListener();
  });

  // Simulate ticket
  elements.btnSimulateTicket.addEventListener('click', simulateNewTicket);

  // Status Changer Buttons in Modal
  elements.modalStatusGroup.querySelectorAll('.btn-status-option').forEach(btn => {
    btn.addEventListener('click', () => {
      const newStatus = btn.getAttribute('data-status');
      updateTicketStatus(newStatus);
    });
  });

  // Template pills in Modal
  elements.templatePills.querySelectorAll('.template-pill').forEach(pill => {
    pill.addEventListener('click', () => {
      const key = pill.getAttribute('data-template');
      applyTemplate(key);
    });
  });

  // Send Email Response
  elements.btnSendEmailResponse.addEventListener('click', sendSupportEmail);

  // Close Detail Modal
  elements.closeDetailModalBtn.addEventListener('click', () => closeModal(elements.ticketDetailModal));
  elements.btnCancelModal.addEventListener('click', () => closeModal(elements.ticketDetailModal));
  elements.ticketDetailModal.addEventListener('click', (e) => {
    if (e.target === elements.ticketDetailModal) closeModal(elements.ticketDetailModal);
  });

  // Auth Modal Triggers
  elements.authModalTrigger.addEventListener('click', () => openModal(elements.agentAuthModal));
  elements.closeAuthModalBtn.addEventListener('click', () => closeModal(elements.agentAuthModal));
  elements.agentAuthModal.addEventListener('click', (e) => {
    if (e.target === elements.agentAuthModal) closeModal(elements.agentAuthModal);
  });

  // Global ESC key listener to close modals
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      closeModal(elements.ticketDetailModal);
      closeModal(elements.agentAuthModal);
    }
    // Ctrl + K focus search
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
      e.preventDefault();
      elements.searchInput.focus();
    }
  });
}

// Expose for inline handlers in dynamic DOM
window.loadDemoTickets = loadDemoTickets;
window.simulateNewTicket = simulateNewTicket;
window.openModal = openModal;
window.elements = elements;

// ==========================================================
// 14. APPLICATION BOOTSTRAP
// ==========================================================
document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initEvents();
  initAuth();
  startFirestoreListener();
});

