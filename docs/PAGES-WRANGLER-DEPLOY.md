# Deploy Pages with Wrangler (Local Build)

## Overview

Instead of connecting GitHub to Cloudflare Pages, you can build locally and deploy directly using Wrangler. This is useful for:
- Quick deployments without GitHub integration
- Testing builds locally before deploying
- Manual control over deployments

## Prerequisites

1. **Wrangler installed:**
   ```bash
   npm install -g wrangler
   # OR use local version
   cd apps-api/workers
   npm install
   ```

2. **Authenticated with Cloudflare:**
   ```bash
   wrangler login
   ```

3. **Pages project exists:**
   - Created by Terraform: `escriturashoy-public-staging`
   - Or create manually: `wrangler pages project create escriturashoy-public-staging`

## Step-by-Step Deployment

### Step 1: Build Locally

```bash
cd apps/public
npm install
npm run build
```

This creates the `dist/` directory with the built site.

### Step 2: Deploy with Wrangler

```bash
# From apps/public directory
npx wrangler pages deploy dist \
  --project-name=escriturashoy-public-staging \
  --branch=main
```

**Or from repo root:**
```bash
cd apps/public
npm run build
npx wrangler pages deploy dist \
  --project-name=escriturashoy-public-staging
```

### Step 3: Verify Deployment

```bash
# Wait 30-60 seconds for deployment
curl -I https://staging.escriturashoy.com

# Should return: HTTP/2 200
```

## Create Deployment Script

Add a deploy script to `apps/public/package.json`:

```json
{
  "scripts": {
    "build": "vite build",
    "deploy": "npm run build && wrangler pages deploy dist --project-name=escriturashoy-public-staging"
  }
}
```

Then deploy with:
```bash
cd apps/public
npm run deploy
```

## Environment Variables

If you need environment variables for the build:

```bash
# Set during build
VITE_API_URL=https://api-staging.escriturashoy.com npm run build

# Or create .env file
echo "VITE_API_URL=https://api-staging.escriturashoy.com" > .env
npm run build
```

## Wrangler Pages Commands

### List Projects
```bash
wrangler pages project list
```

### Create Project (if not exists)
```bash
wrangler pages project create escriturashoy-public-staging
```

### List Deployments
```bash
wrangler pages deployment list --project-name=escriturashoy-public-staging
```

### View Deployment Details
```bash
wrangler pages deployment tail --project-name=escriturashoy-public-staging
```

### Delete Deployment
```bash
wrangler pages deployment delete <deployment-id> --project-name=escriturashoy-public-staging
```

## Advantages of Wrangler Deployment

✅ **Fast:** Deploy immediately without waiting for GitHub webhooks  
✅ **Control:** Deploy specific builds, test before deploying  
✅ **No GitHub Required:** Works without connecting GitHub repo  
✅ **Local Testing:** Build and test locally before deploying  

## Disadvantages

❌ **Manual:** Must run command each time (no auto-deploy on push)  
❌ **No Build History:** Less visibility in Cloudflare dashboard  
❌ **No Preview Deployments:** Can't preview PRs automatically  

## Recommended Workflow

### For Development/Testing:
Use Wrangler for quick deployments:
```bash
cd apps/public
npm run build
npx wrangler pages deploy dist --project-name=escriturashoy-public-staging
```

### For Production:
Connect GitHub for automatic deployments:
- Auto-deploy on push to `main`
- Preview deployments for PRs
- Build history and logs

## Troubleshooting

### "Project not found"
```bash
# Create the project first
wrangler pages project create escriturashoy-public-staging
```

### "Authentication required"
```bash
wrangler login
```

### "Build failed"
- Check `dist/` directory exists after build
- Verify `npm run build` completes successfully
- Check for build errors in console

### "Deployment succeeded but site shows 522"
- Wait 1-2 minutes for DNS/propagation
- Check deployment status: `wrangler pages deployment list`
- Verify custom domain is configured in Pages dashboard

## Example: Full Deployment Script

Create `scripts/deploy-pages.sh`:

```bash
#!/bin/bash
set -e

echo "🏗️  Building public site..."
cd apps/public
npm install
npm run build

echo "🚀 Deploying to Cloudflare Pages..."
npx wrangler pages deploy dist \
  --project-name=escriturashoy-public-staging \
  --branch=main

echo "✅ Deployment complete!"
echo "🌐 Site: https://staging.escriturashoy.com"
```

Make executable:
```bash
chmod +x scripts/deploy-pages.sh
```

Run:
```bash
./scripts/deploy-pages.sh
```

---

*Last updated: 2025-12-11*

