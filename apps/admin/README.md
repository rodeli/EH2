# Escriturashoy Admin Portal

Admin portal for Escriturashoy, allowing staff to manage leads and expedientes.

## Development

### Prerequisites

- Node.js 18+
- npm or pnpm

### Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start development server:
   ```bash
   npm run dev
   ```

   The site will be available at `http://localhost:3002`

### Build

Build for production:
```bash
npm run build
```

The output will be in the `dist/` directory.

## Features

- **Dashboard**: Overview with stats and recent items
- **Leads Table**: View all leads with status
- **Expedientes Table**: View all expedientes with status

## Status

This is a skeleton implementation. Full features to be added:
- Real authentication
- API integration for leads and expedientes
- Filters and search
- Detail views
- Edit capabilities
- User management

## Deployment

Deployment will be handled via Cloudflare Pages when configured.

## Access Control

This portal should be protected by Cloudflare Zero Trust for production use.

