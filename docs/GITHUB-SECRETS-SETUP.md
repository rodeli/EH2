# GitHub Secrets Setup Guide

## Overview

To deploy Escriturashoy 2.0 to Cloudflare, you need to configure GitHub Secrets for the CI/CD workflows.

## Required Secrets

### 1. CLOUDFLARE_API_TOKEN

**What it is:** Cloudflare API token with permissions to manage resources

**How to create:**
1. Go to: https://dash.cloudflare.com/profile/api-tokens
2. Click "Create Token"
3. Use "Edit zone DNS" template or create custom token
4. Required permissions:
   - Zone: DNS:Edit
   - Zone: Zone:Read
   - Account: Cloudflare Pages:Edit
   - Account: Workers Scripts:Edit
   - Account: D1:Edit
   - Account: Workers KV Storage:Edit
   - Account: Object Storage:Edit (this is R2 - look for "Object Storage" in the dropdown)
5. Copy the token (you won't see it again!)

**Add to GitHub:**
- Go to: `https://github.com/rodeli/EH2/settings/secrets/actions`
- Click "New repository secret"
- Name: `CLOUDFLARE_API_TOKEN`
- Value: Paste your token
- Click "Add secret"

### 2. CLOUDFLARE_ACCOUNT_ID

**What it is:** Your Cloudflare account ID

**How to find:**
1. Go to: https://dash.cloudflare.com/
2. Select your account
3. The Account ID is shown in the right sidebar
4. Or go to any zone, the Account ID is in the URL

**Add to GitHub:**
- Name: `CLOUDFLARE_ACCOUNT_ID`
- Value: Your account ID (e.g., `abc123def456...`)

### 3. CLOUDFLARE_ZONE_ID

**What it is:** Zone ID for `escriturashoy.com`

**How to find:**
1. Go to: https://dash.cloudflare.com/
2. Select the `escriturashoy.com` zone
3. Scroll down on the Overview page
4. The Zone ID is shown in the API section
5. Or check the URL when viewing the zone

**Add to GitHub:**
- Name: `CLOUDFLARE_ZONE_ID`
- Value: Your zone ID (e.g., `xyz789abc123...`)

## Verification

After adding secrets, you can verify they're set:
1. Go to: `https://github.com/rodeli/EH2/settings/secrets/actions`
2. You should see all three secrets listed
3. Note: You can't view the values, only confirm they exist

## Testing Secrets

The secrets will be used automatically when:
- A PR is created that touches `infra/cloudflare/**`
- Code is merged to `main` branch

You can also test manually by:
1. Creating a test PR
2. Checking the Terraform workflow runs
3. Reviewing the Terraform plan output

## Security Notes

- ⚠️ **Never commit secrets to the repository**
- ⚠️ **Never share secrets in chat or email**
- ✅ **Use GitHub Secrets for all sensitive values**
- ✅ **Rotate tokens regularly**
- ✅ **Use least-privilege permissions**

## Troubleshooting

### "Secret not found" error
- Verify secret name matches exactly (case-sensitive)
- Check you're in the correct repository
- Ensure you have admin access to the repo

### "Permission denied" error
- Check API token has all required permissions
- Verify account ID is correct
- Ensure zone ID matches the correct zone

### Terraform plan fails
- Check all three secrets are set
- Verify API token is valid and not expired
- Confirm account and zone IDs are correct

---

*Last updated: 2025-12-11*

