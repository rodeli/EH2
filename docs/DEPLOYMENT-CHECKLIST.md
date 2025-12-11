# Deployment Checklist

Use this checklist to track deployment progress.

## Pre-Deployment

### Code & Tests
- [x] All code committed
- [x] Tests passing (6/6 API tests)
- [x] All apps build successfully
- [x] TypeScript compilation successful
- [x] Compliance elements verified

### Configuration
- [ ] GitHub Secrets configured
  - [ ] `CLOUDFLARE_API_TOKEN`
  - [ ] `CLOUDFLARE_ACCOUNT_ID`
  - [ ] `CLOUDFLARE_ZONE_ID`
- [ ] Terraform variables verified
- [ ] Wrangler.toml database_id verified

## Deployment Steps

### Step 1: Commit & Push
- [ ] Commit all changes
- [ ] Push to GitHub
- [ ] Verify CI runs successfully

### Step 2: Infrastructure (Terraform)
- [ ] Review Terraform plan in PR or manually
- [ ] Apply Terraform (creates all Cloudflare resources)
- [ ] Verify resources created:
  - [ ] D1 Database
  - [ ] KV Namespace
  - [ ] R2 Bucket
  - [ ] Pages Project
  - [ ] DNS Records

### Step 3: API Worker
- [ ] Get database_id from Terraform output
- [ ] Update wrangler.toml if needed
- [ ] Deploy Worker: `npm run deploy:staging`
- [ ] Verify Worker is accessible
- [ ] Test endpoints

### Step 4: Pages Deployment
- [ ] Verify Pages project created by Terraform
- [ ] Connect repository to Pages (if needed)
- [ ] Verify build succeeds
- [ ] Check site is accessible

### Step 5: Testing
- [ ] Test public site loads
- [ ] Test lead form submission
- [ ] Verify lead in database
- [ ] Test API endpoints
- [ ] Verify compliance elements

## Post-Deployment

### Verification
- [ ] All sites accessible
- [ ] API responding correctly
- [ ] Database queries working
- [ ] Forms submitting successfully
- [ ] No console errors

### Documentation
- [ ] Update deployment status
- [ ] Document any issues encountered
- [ ] Note any manual steps required

## Rollback Plan

If issues occur:
1. Rollback Worker: `wrangler rollback --env staging`
2. Rollback Terraform: `terraform apply` with previous state
3. Revert code: `git revert` or `git reset`

---

*Checklist started: 2025-12-11*

