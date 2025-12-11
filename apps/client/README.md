# Escriturashoy Client Portal

Client portal for Escriturashoy, allowing clients to view their expedientes.

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

   The site will be available at `http://localhost:3001`

### Build

Build for production:
```bash
npm run build
```

The output will be in the `dist/` directory.

## Features

- **Login**: Simple login form (mock authentication for development)
- **Expedientes View**: List of client's expedientes with status

## Status

This is a skeleton implementation. Full features to be added:
- Real authentication
- API integration for expedientes
- Document upload
- Status updates
- Communication with team

## Deployment

Deployment will be handled via Cloudflare Pages when configured.

