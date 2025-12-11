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
    // For now, show empty state since we don't have expedientes yet
    // In production, this would call: GET /expedientes?client_id=...
    listElement.innerHTML = '';
    emptyState.style.display = 'block';

    // Example of what the API call would look like:
    // const response = await fetch(`${API_BASE_URL}/expedientes?client_id=${currentUser.id}`);
    // const data = await response.json();
    // renderExpedientes(data.expedientes);

  } catch (error) {
    console.error('Error loading expedientes:', error);
    listElement.innerHTML = '<div class="loading">Error al cargar expedientes</div>';
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

