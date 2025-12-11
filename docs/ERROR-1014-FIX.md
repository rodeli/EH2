# Error 1014: CNAME Cross-User Banned - Fix

## Issue

When accessing `staging.escriturashoy.com`, you see:
```
Error 1014: CNAME Cross-User Banned
```

## Cause

This error occurs when:
1. A CNAME DNS record points to a Cloudflare resource (like Pages) in a different Cloudflare account
2. Or there's a conflict between a manual DNS record and Cloudflare Pages custom domain

## Solution Applied

We removed the manual DNS record (`cloudflare_dns_record.staging_pages`) because:

1. **Pages Custom Domain Handles DNS**: When you add a custom domain to a Pages project using `cloudflare_pages_domain`, Cloudflare automatically creates and manages the DNS record.

2. **Conflict Prevention**: Having both a manual DNS record and a Pages custom domain can cause conflicts, especially if they point to different targets.

3. **Correct Configuration**: The `cloudflare_pages_domain` resource in `pages.tf` properly configures `staging.escriturashoy.com` for the Pages project.

## What Changed

**Before:**
- Manual DNS record: `staging` CNAME → `staging.pages.dev`
- Pages custom domain: `staging.escriturashoy.com`

**After:**
- Pages custom domain: `staging.escriturashoy.com` (handles DNS automatically)
- No manual DNS record needed

## Verification

After Terraform applies:

1. **Check Pages Domain:**
   - Go to: https://dash.cloudflare.com → Pages → `escriturashoy-public-staging`
   - Check "Custom domains" section
   - Verify `staging.escriturashoy.com` is listed

2. **Check DNS:**
   - Go to: https://dash.cloudflare.com → escriturashoy.com → DNS
   - Verify there's a CNAME record for `staging` (created automatically by Pages)
   - It should point to the Pages project, not `staging.pages.dev`

3. **Test Access:**
   - Visit: `https://staging.escriturashoy.com`
   - Should load the Pages site without Error 1014

## If Error Persists

If you still see Error 1014 after Terraform applies:

1. **Check for Existing DNS Record:**
   - Go to Cloudflare DNS dashboard
   - Look for any `staging` CNAME record
   - Delete it if it points to `staging.pages.dev` or wrong target

2. **Verify Pages Project:**
   - Ensure Pages project exists in the same Cloudflare account
   - Check account ID matches in Terraform variables

3. **Re-add Custom Domain:**
   - In Pages dashboard, remove and re-add the custom domain
   - This will recreate the DNS record correctly

4. **Check Zone Hold:**
   - Ensure zone hold is disabled on `escriturashoy.com`
   - Zone hold can prevent custom domains from working

## Related Documentation

- [Cloudflare Error 1014 Support](https://developers.cloudflare.com/support/troubleshooting/http-status-codes/cloudflare-1xxx-errors/error-1014/)
- [Pages Custom Domains](https://developers.cloudflare.com/pages/platform/custom-domains/)

---

*Last updated: 2025-12-11*

