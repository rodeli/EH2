/**
 * Client Portal App
 * Simple login and expedientes view
 */

const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://api-staging.escriturashoy.com';

// Mock authentication for development
let isAuthenticated = false;
let currentUser = null;

/**
 * Show message
 */
function showMessage(elementId, message, type = 'error') {
  const element = document.getElementById(elementId);
  if (element) {
    element.textContent = message;
    element.className = `form-message ${type}`;
    element.style.display = 'block';
  }
}

/**
 * Hide message
 */
function hideMessage(elementId) {
  const element = document.getElementById(elementId);
  if (element) {
    element.style.display = 'none';
  }
}

/**
 * Handle login form submission
 */
function handleLogin(event) {
  event.preventDefault();
  hideMessage('login-message');

  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;

  // Mock authentication - in production, this would call an auth API
  if (email && password) {
    isAuthenticated = true;
    currentUser = { email, name: email.split('@')[0] };

    // Update UI
    document.getElementById('user-info').textContent = currentUser.name;
    document.getElementById('login-view').style.display = 'none';
    document.getElementById('dashboard-view').style.display = 'block';

    // Load expedientes
    loadExpedientes();
  } else {
    showMessage('login-message', 'Por favor, completa todos los campos', 'error');
  }
}

/**
 * Load expedientes from API
 */
async function loadExpedientes() {
  const listElement = document.getElementById('expedientes-list');
  const emptyState = document.getElementById('empty-state');

  try {
    listElement.innerHTML = '<div class="loading">Cargando expedientes...</div>';
    emptyState.style.display = 'none';

    // Build query params
    const params = new URLSearchParams({ limit: '50' });
    // TODO: Add client_id filter when authentication is implemented
    // if (currentUser?.id) {
    //   params.append('client_id', currentUser.id);
    // }

    const response = await fetch(`${API_BASE_URL}/expedientes?${params}`);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const result = await response.json();
    if (result.success && result.data) {
      renderExpedientes(result.data);
    } else {
      throw new Error('Invalid response format');
    }
  } catch (error) {
    console.error('Error loading expedientes:', error);
    listElement.innerHTML = '';
    emptyState.style.display = 'block';
    emptyState.innerHTML = `
      <p>Error al cargar expedientes: ${error.message}</p>
      <p>Verifica que la API esté disponible.</p>
    `;
  }
}

/**
 * Render expedientes list
 */
function renderExpedientes(expedientes) {
  const listElement = document.getElementById('expedientes-list');
  const emptyState = document.getElementById('empty-state');

  if (!expedientes || expedientes.length === 0) {
    listElement.innerHTML = '';
    emptyState.style.display = 'block';
    return;
  }

  emptyState.style.display = 'none';

  listElement.innerHTML = expedientes.map(exp => `
    <div class="expediente-card">
      <div class="expediente-header">
        <span class="expediente-id">Expediente #${exp.id.substring(0, 8)}</span>
        <span class="expediente-status status-${exp.status}">${exp.status}</span>
      </div>
      <div class="expediente-info">
        <p><strong>Ubicación:</strong> ${exp.property_location}</p>
        <p><strong>Tipo:</strong> ${exp.type}</p>
        <p><strong>Fecha:</strong> ${new Date(exp.created_at * 1000).toLocaleDateString('es-MX')}</p>
      </div>
    </div>
  `).join('');
}

/**
 * Initialize app
 */
document.addEventListener('DOMContentLoaded', () => {
  const loginForm = document.getElementById('login-form');
  if (loginForm) {
    loginForm.addEventListener('submit', handleLogin);
  }

  // Check if already authenticated (in production, check token)
  // For now, always show login
});

