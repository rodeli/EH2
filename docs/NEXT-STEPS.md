# Next Steps - Escriturashoy 2.0

## Current Status

**Milestones Completed:**
- ✅ Milestone 0: Repo & Governance Baseline
- ✅ Milestone 1: Cloudflare Staging Baseline
- ✅ Milestone 3: App Skeletons & First Real Workflow

**Ready for:** Staging deployment and testing

## Immediate Next Steps

### 1. Commit Current Work

All changes are ready to commit:
```bash
git add -A
git commit -m "feat: Complete Milestone 3 - App skeletons and first workflow

- Add database schema and migrations
- Implement API endpoints (POST /leads, GET /expedientes/:id)
- Create marketing site with lead form
- Add client and admin portal skeletons
- Add tests and compliance checks
- Update documentation"
git push origin main
```

### 2. Deploy to Staging

#### A. Apply Terraform Infrastructure

**Prerequisites:**
- Cloudflare API token with appropriate permissions
- Cloudflare account ID
- Zone ID for escriturashoy.com

**Steps:**
1. Configure GitHub Secrets:
   - `CLOUDFLARE_API_TOKEN`
   - `CLOUDFLARE_ACCOUNT_ID`
   - `CLOUDFLARE_ZONE_ID`

2. Terraform will run automatically on merge to main, or manually:
   ```bash
   cd infra/cloudflare
   terraform init
   terraform plan
   terraform apply
   ```

#### B. Deploy API Worker

```bash
cd apps-api/workers
npm run deploy:staging
```

#### C. Deploy Pages Projects

Pages will deploy automatically via Cloudflare Pages when:
- Terraform creates the Pages projects
- Code is pushed to main branch
- Or manually via Cloudflare dashboard

### 3. Test End-to-End Flow

1. **Test Lead Form:**
   - Visit `staging.escriturashoy.com`
   - Fill out lead form
   - Submit and verify lead is created
   - Check database: `wrangler d1 execute escriturashoy-staging-db --command="SELECT * FROM leads LIMIT 5;" --remote`

2. **Test API Endpoints:**
   ```bash
   # Health check
   curl https://api-staging.escriturashoy.com/health

   # Create lead
   curl -X POST https://api-staging.escriturashoy.com/leads \
     -H "Content-Type: application/json" \
     -d '{"name":"Test","email":"test@example.com","property_location":"CDMX","property_type":"casa"}'
   ```

3. **Verify Compliance:**
   - Check legal disclaimers are visible
   - Verify privacy consent is required
   - Confirm privacy/terms links are present

## Short-term Enhancements

### 1. Complete Missing Pages
- Create `/privacidad` page (privacy policy)
- Create `/terminos` page (terms of service)

### 2. Add Missing API Endpoints
- `GET /leads` - List leads (for admin)
- `GET /expedientes` - List expedientes (for admin/client)
- `POST /expedientes` - Create expediente

### 3. Enhance Portals
- Real authentication (replace mock)
- API integration for client/admin
- Document upload functionality

## Medium-term Milestones

### Milestone 2: 1.00.ge Internal Infra & Observability
- Define VMs in Terraform/Ansible
- Set up Cloudflare Tunnel
- Configure logging pipeline
- Set up basic alerts

### Milestone 4: Customer Support Agent & Deeper Workflows
- AI support agent integration
- Complete expediente workflows
- Role-based access control
- Production environment setup

## Deployment Checklist

### Pre-Deployment
- [x] All code committed
- [x] Tests passing
- [x] Builds successful
- [ ] GitHub Secrets configured
- [ ] Terraform variables verified

### Deployment
- [ ] Terraform apply (creates all resources)
- [ ] Worker deployed to staging
- [ ] Pages projects deployed
- [ ] DNS records verified

### Post-Deployment
- [ ] End-to-end lead form test
- [ ] API endpoints tested
- [ ] Database queries verified
- [ ] Compliance elements verified
- [ ] Performance check

## Recommended Order

1. **Commit and push** current work
2. **Configure GitHub Secrets** for Terraform
3. **Apply Terraform** (via PR or manual)
4. **Deploy Worker** manually first time
5. **Test end-to-end** flow
6. **Create missing pages** (privacy, terms)
7. **Add missing API endpoints**
8. **Proceed with Milestone 2 or 4**

## Notes

- The database is already created and migrations run
- Worker binding is configured in wrangler.toml
- All apps are ready to deploy
- CI/CD will handle future deployments automatically

---

*Last updated: 2025-12-11*

