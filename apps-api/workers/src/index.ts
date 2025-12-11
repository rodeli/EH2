/**
 * Escriturashoy API Worker
 *
 * Main entry point for the API Worker handling requests to api-staging.escriturashoy.com
 */

// UUID generation for Cloudflare Workers
// Using crypto.randomUUID() which is available in Workers runtime
function uuidv4(): string {
  return crypto.randomUUID();
}

export interface Env {
  // D1 Database binding
  DB: D1Database;

  // KV Namespace binding
  CONFIG?: KVNamespace;

  // R2 Bucket binding
  DOCS?: R2Bucket;

  // Environment variables
  ENVIRONMENT?: string;
  VERSION?: string;
}

/**
 * Get version information
 * In production, this could read from git SHA or package version
 */
function getVersion(env: Env): string {
  return env.VERSION || '0.1.0-dev';
}

/**
 * Get current Unix timestamp
 */
function getTimestamp(): number {
  return Math.floor(Date.now() / 1000);
}

/**
 * Generate UUID v4
 */
function generateId(): string {
  return uuidv4();
}

/**
 * Health check endpoint
 * Returns 200 OK if the worker is running
 */
async function handleHealth(): Promise<Response> {
  return new Response(JSON.stringify({
    status: 'ok',
    timestamp: new Date().toISOString(),
  }), {
    headers: {
      'Content-Type': 'application/json',
    },
  });
}

/**
 * Version endpoint
 * Returns the current version of the API
 */
async function handleVersion(env: Env): Promise<Response> {
  return new Response(JSON.stringify({
    version: getVersion(env),
    environment: env.ENVIRONMENT || 'unknown',
    timestamp: new Date().toISOString(),
  }), {
    headers: {
      'Content-Type': 'application/json',
    },
  });
}

/**
 * Create a new lead
 * POST /leads
 * Body: { name, email, phone?, property_location, property_type, urgency? }
 */
async function handleCreateLead(request: Request, env: Env): Promise<Response> {
  try {
    const body = await request.json() as {
      name: string;
      email: string;
      phone?: string;
      property_location: string;
      property_type: 'casa' | 'departamento' | 'terreno' | 'comercial';
      urgency?: 'alta' | 'media' | 'baja';
    };

    // Validation
    if (!body.name || !body.email || !body.property_location || !body.property_type) {
      return new Response(JSON.stringify({
        error: 'Validation Error',
        message: 'Missing required fields: name, email, property_location, property_type',
      }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // Validate property_type
    const validPropertyTypes = ['casa', 'departamento', 'terreno', 'comercial'];
    if (!validPropertyTypes.includes(body.property_type)) {
      return new Response(JSON.stringify({
        error: 'Validation Error',
        message: `Invalid property_type. Must be one of: ${validPropertyTypes.join(', ')}`,
      }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // Validate urgency if provided
    if (body.urgency) {
      const validUrgency = ['alta', 'media', 'baja'];
      if (!validUrgency.includes(body.urgency)) {
        return new Response(JSON.stringify({
          error: 'Validation Error',
          message: `Invalid urgency. Must be one of: ${validUrgency.join(', ')}`,
        }), {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        });
      }
    }

    const id = generateId();
    const now = getTimestamp();

    // Insert lead
    const result = await env.DB.prepare(`
      INSERT INTO leads (
        id, name, email, phone, property_location, property_type, urgency, status, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, 'nuevo', ?, ?)
    `).bind(
      id,
      body.name,
      body.email,
      body.phone || null,
      body.property_location,
      body.property_type,
      body.urgency || null,
      now,
      now
    ).run();

    if (!result.success) {
      return new Response(JSON.stringify({
        error: 'Database Error',
        message: 'Failed to create lead',
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // Fetch the created lead
    const lead = await env.DB.prepare(`
      SELECT * FROM leads WHERE id = ?
    `).bind(id).first();

    return new Response(JSON.stringify({
      success: true,
      data: lead,
    }), {
      status: 201,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}

/**
 * Get all leads (for admin portal)
 * GET /leads
 * Query params: status?, limit?, offset?
 */
async function handleGetLeads(request: Request, env: Env): Promise<Response> {
  try {
    const url = new URL(request.url);
    const status = url.searchParams.get('status');
    const limit = parseInt(url.searchParams.get('limit') || '50', 10);
    const offset = parseInt(url.searchParams.get('offset') || '0', 10);

    let query = 'SELECT * FROM leads';
    const params: any[] = [];

    if (status) {
      query += ' WHERE status = ?';
      params.push(status);
    }

    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    const leads = await env.DB.prepare(query).bind(...params).all();

    // Get total count for pagination
    let countQuery = 'SELECT COUNT(*) as total FROM leads';
    if (status) {
      countQuery += ' WHERE status = ?';
    }
    const countResult = await env.DB.prepare(countQuery).bind(...(status ? [status] : [])).first<{ total: number }>();

    return new Response(JSON.stringify({
      success: true,
      data: leads.results || [],
      pagination: {
        total: countResult?.total || 0,
        limit,
        offset,
      },
    }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}

/**
 * Get expediente by ID
 * GET /expedientes/:id
 */
async function handleGetExpediente(request: Request, env: Env, pathParams: { id: string }): Promise<Response> {
  try {
    const { id } = pathParams;

    const expediente = await env.DB.prepare(`
      SELECT
        e.*,
        c.name as client_name,
        c.email as client_email,
        l.name as lead_name
      FROM expedientes e
      LEFT JOIN clients c ON e.client_id = c.id
      LEFT JOIN leads l ON e.lead_id = l.id
      WHERE e.id = ?
    `).bind(id).first();

    if (!expediente) {
      return new Response(JSON.stringify({
        error: 'Not Found',
        message: 'Expediente not found',
      }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({
      success: true,
      data: expediente,
    }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}

/**
 * Get all expedientes (for admin/client portals)
 * GET /expedientes
 * Query params: client_id?, status?, limit?, offset?
 */
async function handleGetExpedientes(request: Request, env: Env): Promise<Response> {
  try {
    const url = new URL(request.url);
    const clientId = url.searchParams.get('client_id');
    const status = url.searchParams.get('status');
    const limit = parseInt(url.searchParams.get('limit') || '50', 10);
    const offset = parseInt(url.searchParams.get('offset') || '0', 10);

    let query = `
      SELECT
        e.*,
        c.name as client_name,
        c.email as client_email,
        l.name as lead_name
      FROM expedientes e
      LEFT JOIN clients c ON e.client_id = c.id
      LEFT JOIN leads l ON e.lead_id = l.id
    `;
    const conditions: string[] = [];
    const params: any[] = [];

    if (clientId) {
      conditions.push('e.client_id = ?');
      params.push(clientId);
    }

    if (status) {
      conditions.push('e.status = ?');
      params.push(status);
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY e.created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    const expedientes = await env.DB.prepare(query).bind(...params).all();

    // Get total count for pagination
    let countQuery = 'SELECT COUNT(*) as total FROM expedientes e';
    if (conditions.length > 0) {
      countQuery += ' WHERE ' + conditions.join(' AND ');
    }
    const countParams = params.slice(0, -2); // Remove limit and offset
    const countResult = await env.DB.prepare(countQuery).bind(...countParams).first<{ total: number }>();

    return new Response(JSON.stringify({
      success: true,
      data: expedientes.results || [],
      pagination: {
        total: countResult?.total || 0,
        limit,
        offset,
      },
    }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}

/**
 * 404 Not Found handler
 */
function handleNotFound(): Response {
  return new Response(JSON.stringify({
    error: 'Not Found',
    message: 'The requested resource was not found.',
  }), {
    status: 404,
    headers: {
      'Content-Type': 'application/json',
    },
  });
}

/**
 * Parse URL and extract path parameters
 */
function parsePath(pathname: string): { path: string; params: Record<string, string> } {
  const parts = pathname.split('/').filter(p => p);
  const params: Record<string, string> = {};

  // Match patterns like /expedientes/:id
  if (parts.length === 2 && parts[0] === 'expedientes') {
    return { path: '/expedientes/:id', params: { id: parts[1] } };
  }

  // Match /expedientes (list) or /leads (list)
  if (parts.length === 1) {
    if (parts[0] === 'expedientes') {
      return { path: '/expedientes', params: {} };
    }
    if (parts[0] === 'leads') {
      return { path: '/leads', params: {} };
    }
  }

  return { path: '/' + parts.join('/'), params };
}

/**
 * Main request handler
 */
export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    const pathname = url.pathname;
    const method = request.method;

    // Parse path
    const { path, params } = parsePath(pathname);

    // Route handling
    if (method === 'GET') {
      switch (path) {
        case '/health':
        case '/health/':
          return handleHealth();

        case '/version':
        case '/version/':
          return handleVersion(env);

        case '/leads':
        case '/leads/':
          return handleGetLeads(request, env);

        case '/expedientes':
        case '/expedientes/':
          return handleGetExpedientes(request, env);

        case '/expedientes/:id':
          return handleGetExpediente(request, env, params as { id: string });

        default:
          return handleNotFound();
      }
    } else if (method === 'POST') {
      switch (path) {
        case '/leads':
        case '/leads/':
          return handleCreateLead(request, env);

        default:
          return handleNotFound();
      }
    }

    return handleNotFound();
  },
};
