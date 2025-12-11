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
    // For now, show empty state since we don't have a GET /leads endpoint yet
    // In production, this would call: GET /leads
    container.innerHTML = `
      <div class="empty-state">
        <p>No hay leads disponibles.</p>
        <p>Los leads aparecerán aquí cuando se creen desde el formulario público.</p>
      </div>
    `;

    // Example of what the API call would look like:
    // const response = await fetch(`${API_BASE_URL}/leads`);
    // const data = await response.json();
    // renderLeads(data.leads);

  } catch (error) {
    console.error('Error loading leads:', error);
    container.innerHTML = '<div class="loading">Error al cargar leads</div>';
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
    // For now, show empty state
    // In production, this would call: GET /expedientes
    container.innerHTML = `
      <div class="empty-state">
        <p>No hay expedientes disponibles.</p>
        <p>Los expedientes aparecerán aquí cuando se creen.</p>
      </div>
    `;

    // Example of what the API call would look like:
    // const response = await fetch(`${API_BASE_URL}/expedientes`);
    // const data = await response.json();
    // renderExpedientes(data.expedientes);

  } catch (error) {
    console.error('Error loading expedientes:', error);
    container.innerHTML = '<div class="loading">Error al cargar expedientes</div>';
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
  document.getElementById('expedientes-count').textContent = expedientes?.length || 0;
  // Calculate new this week (placeholder)
  document.getElementById('new-count').textContent = '-';
}

/**
 * Initialize app
 */
document.addEventListener('DOMContentLoaded', () => {
  loadLeads();
  loadExpedientes();
  // updateStats(leads, expedientes);
});

