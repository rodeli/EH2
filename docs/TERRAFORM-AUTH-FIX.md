# Terraform Authentication Fix

## Issue

Terraform is failing with authentication errors:
- `401 Unauthorized` for D1 database
- `403 Forbidden` for KV, Pages, R2, and DNS

This indicates the API token doesn't have sufficient permissions.

## Solution

### Step 1: Verify Current Token Permissions

1. Go to: https://dash.cloudflare.com/profile/api-tokens
2. Find your current token (or create a new one)
3. Check it has these permissions:

**Required Permissions:**

#### Account Level:
- ✅ **Account** → **Cloudflare Pages** → **Edit**
- ✅ **Account** → **Workers Scripts** → **Edit**
- ✅ **Account** → **D1** → **Edit**
- ✅ **Account** → **Workers KV Storage** → **Edit**
- ✅ **Account** → **Object Storage** → **Edit** (this is R2)

#### Zone Level:
- ✅ **Zone** → **DNS** → **Edit**
- ✅ **Zone** → **Zone** → **Read**

### Step 2: Create New Token (Recommended)

If your current token doesn't have all permissions, create a new one:

1. Go to: https://dash.cloudflare.com/profile/api-tokens
2. Click **"Create Token"**
3. Click **"Create Custom Token"**
4. Configure:

   **Token Name:** `Escriturashoy Terraform`

   **Permissions:**
   - **Account** → **Cloudflare Pages** → **Edit**
   - **Account** → **Workers Scripts** → **Edit**
   - **Account** → **D1** → **Edit**
   - **Account** → **Workers KV Storage** → **Edit**
   - **Account** → **Object Storage** → **Edit** (this is R2 - look for "Object Storage" in the dropdown)
   - **Zone** → **DNS** → **Edit** (select `escriturashoy.com`)
   - **Zone** → **Zone** → **Read** (select `escriturashoy.com`)

   **Account Resources:**
   - Include → **All accounts** (or select your specific account)

   **Zone Resources:**
   - Include → **Specific zone** → `escriturashoy.com`

5. Click **"Continue to summary"**
6. Click **"Create Token"**
7. **Copy the token immediately** (you won't see it again!)

### Step 3: Update GitHub Secret

1. Go to: https://github.com/rodeli/EH2/settings/secrets/actions
2. Find `CLOUDFLARE_API_TOKEN`
3. Click **"Update"**
4. Paste your new token
5. Click **"Update secret"**

### Step 4: Retry Terraform

After updating the secret, the next Terraform run should work. You can:

**Option A: Wait for next push**
- Any change to `infra/cloudflare/**` will trigger Terraform

**Option B: Trigger manually**
```bash
# Make a small change to trigger workflow
echo "# Retry Terraform" >> infra/cloudflare/README.md
git add infra/cloudflare/README.md
git commit -m "chore: Retry Terraform with updated token"
git push origin main
```

## Verification

After updating the token, check the Terraform workflow:
- Go to: https://github.com/rodeli/EH2/actions
- Look for the latest "Terraform Apply" run
- It should now succeed instead of showing authentication errors

## Common Issues

### Token has wrong account
- Ensure the token is created for the correct Cloudflare account
- Check `CLOUDFLARE_ACCOUNT_ID` matches the account where the token was created

### Token expired
- API tokens don't expire, but check if it was revoked
- Create a new token if unsure

### Zone not included
- Ensure the token has permissions for `escriturashoy.com` zone
- Check zone resources include the correct zone

### R2 permission not found
- In the Cloudflare API token UI, R2 permissions are listed as **"Object Storage"** (not "R2")
- Look for: **Account** → **Object Storage** → **Edit**
- This permission allows creating and managing R2 buckets

---

*Last updated: 2025-12-11*


