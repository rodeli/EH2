/**
 * Admin Portal App
 * Dashboard with leads and expedientes tables
 */

const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://api-staging.escriturashoy.com';

/**
 * Load and render leads
 */
async function loadLeads() {
  const container = document.getElementById('leads-table-container');

  try {
    container.innerHTML = '<div class="loading">Cargando leads...</div>';

    const response = await fetch(`${API_BASE_URL}/leads?limit=20`);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const result = await response.json();
    if (result.success && result.data) {
      renderLeads(result.data);
      return result.data;
    } else {
      throw new Error('Invalid response format');
    }
  } catch (error) {
    console.error('Error loading leads:', error);
    container.innerHTML = `
      <div class="empty-state">
        <p>Error al cargar leads: ${error.message}</p>
        <p>Verifica que la API esté disponible.</p>
      </div>
    `;
    return [];
  }
}

/**
 * Render leads table
 */
function renderLeads(leads) {
  const container = document.getElementById('leads-table-container');

  if (!leads || leads.length === 0) {
    container.innerHTML = '<div class="empty-state">No hay leads disponibles</div>';
    return;
  }

  container.innerHTML = `
    <table>
      <thead>
        <tr>
          <th>Nombre</th>
          <th>Email</th>
          <th>Teléfono</th>
          <th>Ubicación</th>
          <th>Tipo</th>
          <th>Urgencia</th>
          <th>Estado</th>
          <th>Fecha</th>
        </tr>
      </thead>
      <tbody>
        ${leads.map(lead => `
          <tr>
            <td>${lead.name}</td>
            <td>${lead.email}</td>
            <td>${lead.phone || '-'}</td>
            <td>${lead.property_location}</td>
            <td>${lead.property_type}</td>
            <td>${lead.urgency || '-'}</td>
            <td><span class="status-badge status-${lead.status}">${lead.status}</span></td>
            <td>${new Date(lead.created_at * 1000).toLocaleDateString('es-MX')}</td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  `;
}

/**
 * Load and render expedientes
 */
async function loadExpedientes() {
  const container = document.getElementById('expedientes-table-container');

  try {
    container.innerHTML = '<div class="loading">Cargando expedientes...</div>';

    const response = await fetch(`${API_BASE_URL}/expedientes?limit=20`);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const result = await response.json();
    if (result.success && result.data) {
      renderExpedientes(result.data);
      return result.data;
    } else {
      throw new Error('Invalid response format');
    }
  } catch (error) {
    console.error('Error loading expedientes:', error);
    container.innerHTML = `
      <div class="empty-state">
        <p>Error al cargar expedientes: ${error.message}</p>
        <p>Verifica que la API esté disponible.</p>
      </div>
    `;
    return [];
  }
}

/**
 * Render expedientes table
 */
function renderExpedientes(expedientes) {
  const container = document.getElementById('expedientes-table-container');

  if (!expedientes || expedientes.length === 0) {
    container.innerHTML = '<div class="empty-state">No hay expedientes disponibles</div>';
    return;
  }

  container.innerHTML = `
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Cliente</th>
          <th>Ubicación</th>
          <th>Tipo</th>
          <th>Estado</th>
          <th>Fecha</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        ${expedientes.map(exp => `
          <tr>
            <td>${exp.id.substring(0, 8)}...</td>
            <td>${exp.client_name || exp.client_email || '-'}</td>
            <td>${exp.property_location}</td>
            <td>${exp.type}</td>
            <td><span class="status-badge status-${exp.status}">${exp.status}</span></td>
            <td>${new Date(exp.created_at * 1000).toLocaleDateString('es-MX')}</td>
            <td><a href="/expedientes/${exp.id}">Ver</a></td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  `;
}

/**
 * Update stats
 */
function updateStats(leads, expedientes) {
  document.getElementById('leads-count').textContent = leads?.length || 0;
  
  // Count active expedientes
  const activeExpedientes = expedientes?.filter(e => e.status === 'activo') || [];
  document.getElementById('expedientes-count').textContent = activeExpedientes.length;
  
  // Calculate new this week
  const weekAgo = Math.floor(Date.now() / 1000) - (7 * 24 * 60 * 60);
  const newThisWeek = leads?.filter(l => l.created_at >= weekAgo).length || 0;
  document.getElementById('new-count').textContent = newThisWeek;
}

/**
 * Initialize app
 */
document.addEventListener('DOMContentLoaded', async () => {
  // Load data in parallel
  const [leads, expedientes] = await Promise.all([
    loadLeads(),
    loadExpedientes()
  ]);
  
  // Update stats with loaded data
  updateStats(leads, expedientes);
});

