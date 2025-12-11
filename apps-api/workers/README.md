# Escriturashoy API Worker

Cloudflare Worker for the Escriturashoy API, handling requests to `api-staging.escriturashoy.com`.

## Development

### Prerequisites

- Node.js 18+
- Wrangler CLI (installed via npm)

### Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Configure Wrangler (create `.dev.vars` file, do not commit):
   ```toml
   CLOUDFLARE_API_TOKEN=your-api-token
   CLOUDFLARE_ACCOUNT_ID=your-account-id
   ```

3. The database binding is configured in `wrangler.toml`:
   ```toml
   [env.staging]
   d1_databases = [
     { binding = "DB", database_name = "escriturashoy-staging-db", database_id = "..." }
   ]
   ```

### Local Development

Run the worker locally:
```bash
npm run dev
```

The worker will be available at `http://localhost:8787`

### Endpoints

#### Health & Version
- `GET /health` - Health check endpoint
- `GET /version` - Version information

#### Leads
- `POST /leads` - Create a new lead
  ```json
  {
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "phone": "+52 55 1234 5678",
    "property_location": "Ciudad de México",
    "property_type": "casa",
    "urgency": "alta"
  }
  ```

#### Expedientes
- `GET /expedientes/:id` - Get expediente by ID

### Database

The worker uses D1 database binding `DB`:
- Database: `escriturashoy-staging-db`
- Tables: `users`, `clients`, `leads`, `expedientes`

See `db/schema/core.md` for schema documentation.

### Deployment

#### Staging

```bash
npm run deploy:staging
```

Or manually:
```bash
wrangler deploy --env staging
```

#### Production

```bash
npm run deploy:production
```

### Bindings

The worker uses the following Cloudflare bindings:

- **D1 Database** (`DB`): Transactional database
- **KV Namespace** (`CONFIG`): Configuration and feature flags (optional)
- **R2 Bucket** (`DOCS`): Document storage (optional)

These bindings are configured in `wrangler.toml` and should match the resources created by Terraform in `infra/cloudflare/`.

### CI/CD

Deployment is handled via GitHub Actions. See `.github/workflows/` for CI configuration.

### Testing

Test endpoints locally:
```bash
# Health check
curl http://localhost:8787/health

# Create lead
curl -X POST http://localhost:8787/leads \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "property_location": "CDMX",
    "property_type": "casa"
  }'
```
