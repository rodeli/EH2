# Escriturashoy Public Site

Marketing and public-facing website for Escriturashoy, deployed via Cloudflare Pages.

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

   The site will be available at `http://localhost:3000`

### Build

Build for production:
```bash
npm run build
```

The output will be in the `dist/` directory, which is configured for Cloudflare Pages deployment.

### Preview

Preview the production build locally:
```bash
npm run preview
```

## Deployment

Deployment is handled automatically via Cloudflare Pages when changes are pushed to the `main` branch.

The site is configured in `infra/cloudflare/pages.tf` and will be available at:
- Staging: `staging.escriturashoy.com`
- Production: (TBD)

## Structure

- `index.html` - Main HTML file
- `styles.css` - Global styles
- `dist/` - Build output (gitignored)

## Sections

The landing page includes:

1. **Hero** - Main heading and value proposition
2. **Cómo funciona** - Step-by-step process explanation
3. **Seguridad y cumplimiento** - Compliance and security information
4. **Contacto** - Contact information and legal disclaimers

