# Error 522: Pages Connection Timeout - Fix

## Issue

When accessing `https://staging.escriturashoy.com`, you get:
```
HTTP/2 522
```

## What This Means

**Error 522** = Connection timed out

This indicates:
- ✅ Pages project exists (created by Terraform)
- ✅ Custom domain is configured (`staging.escriturashoy.com`)
- ❌ **No deployment exists yet** - This is the problem

## Cause

Terraform creates the Pages **project**, but Pages needs:
1. **GitHub repository connection** - Link your repo to the project
2. **Build configuration** - Tell Pages how to build your site
3. **First deployment** - Pages needs to build and deploy the code

## Solution

### Step 1: Connect GitHub Repository

1. Go to: https://dash.cloudflare.com → Pages
2. Click on `escriturashoy-public-staging` project
3. Go to **Settings** → **Builds & deployments**
4. Click **Connect to Git**
5. Select your GitHub repository: `rodeli/EH2`
6. Authorize Cloudflare to access your repository

### Step 2: Configure Build Settings

After connecting the repository, configure build settings:

- **Framework preset:** Vite
- **Build command:** `npm run build`
- **Build output directory:** `dist`
- **Root directory:** `apps/public`
- **Node version:** 20 (or latest LTS)

**Environment variables (if needed):**
- `VITE_API_URL` = `https://api-staging.escriturashoy.com` (optional, for API calls)

### Step 3: Trigger First Deployment

After saving build settings, Pages will:
1. Automatically trigger a deployment from the `main` branch
2. Build your site using the configured settings
3. Deploy to `staging.escriturashoy.com`

**OR** manually trigger:
- Go to **Deployments** tab
- Click **Retry deployment** or **Create deployment**

### Step 4: Verify Deployment

Wait for the deployment to complete (usually 1-3 minutes), then:

```bash
# Should return 200 OK
curl -I https://staging.escriturashoy.com

# Or visit in browser
open https://staging.escriturashoy.com
```

## Alternative: Manual Deployment

If you prefer to deploy manually without GitHub connection:

1. **Build locally:**
   ```bash
   cd apps/public
   npm run build
   ```

2. **Deploy via Wrangler Pages:**
   ```bash
   npx wrangler pages deploy dist --project-name=escriturashoy-public-staging
   ```

   **Note:** This requires Wrangler Pages plugin and authentication.

## Troubleshooting

### Deployment Fails

**Check build logs:**
- Go to Pages dashboard → Deployments
- Click on failed deployment
- Check build logs for errors

**Common issues:**
- Missing dependencies: Add `package-lock.json` or `pnpm-lock.yaml`
- Wrong build command: Verify `npm run build` works locally
- Wrong output directory: Should be `dist` for Vite
- Wrong root directory: Should be `apps/public`

### Site Still Shows 522 After Deployment

1. **Check deployment status:**
   - Verify deployment completed successfully
   - Check if custom domain is properly configured

2. **Wait for DNS propagation:**
   - Can take 1-2 minutes after deployment

3. **Clear cache:**
   - Try incognito/private browsing
   - Or wait a few minutes for cache to clear

### Build Command Not Found

If Pages can't find `npm run build`:
- Ensure `package.json` exists in `apps/public`
- Verify build script is defined in `package.json`
- Check root directory is set to `apps/public`

## Verification

After successful deployment:

1. **Check site loads:**
   ```bash
   curl -I https://staging.escriturashoy.com
   # Should return: HTTP/2 200
   ```

2. **Test lead form:**
   - Visit: https://staging.escriturashoy.com
   - Fill out the form
   - Submit and verify it works

3. **Check API integration:**
   - Form should submit to: `https://api-staging.escriturashoy.com/leads`
   - Verify lead appears in API: `curl https://api-staging.escriturashoy.com/leads`

## Expected Result

After fixing:
- ✅ Site loads at `https://staging.escriturashoy.com`
- ✅ Landing page displays correctly
- ✅ Lead form is functional
- ✅ API integration works

---

*Last updated: 2025-12-11*

