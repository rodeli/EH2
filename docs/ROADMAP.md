# Escriturashoy 2.0 – Technical Roadmap

**Goal:** Rebuild Escriturashoy as a Cloudflare-first, GitOps-driven legal-tech platform, with 1.00.ge as the internal/SRE backbone.

**Operating mode:** All changes via PR, IaC for infra, agents in `docs/AGENTS.md` as the main execution model.

Timeline is indicative. Adjust as needed.

---

## Milestone 0 – Repo & Governance Baseline (Week 0–1)

**Objective:** Have a structured monorepo with clear agent definitions, base CI, and no accidental footguns.

### Outcomes

- Monorepo structure created (apps, infra, db, docs).
- `AGENTS.md` present and referenced by Cursor rules.
- Basic CI running lint/tests on PR.
- Branch protection on `main` enabled.

### Tasks

**M0-T1 – Create monorepo structure**

- **Owner Agent:** Planner / CTO Copilot Agent
- **Description:** Ensure folders exist:
  - `apps/public`, `apps/client`, `apps/admin`
  - `apps-api/workers`
  - `infra/cloudflare`, `infra/100ge`
  - `db/migrations`, `db/schema`
  - `docs/*`
- **Acceptance Criteria:**
  - Repo tree matches the structure in `ARCHITECTURE.md` and `AGENTS.md`.
  - Placeholder files (`README.md` or `.gitkeep`) exist so folders are tracked.
- **Note:** Creating the initial folder structure (and `.gitkeep` placeholders) is treated as a one-time bootstrap task and is allowed for the Planner / CTO Copilot Agent. Ongoing code changes in these paths must be made by the specialized agents defined in `AGENTS.md`.
- **Status:** ✅ Complete

**M0-T2 – Document agents & governance**

- **Owner Agent:** Planner / CTO Copilot Agent
- **Description:** Finalize `docs/AGENTS.md` and add references to it from:
  - `docs/ARCHITECTURE.md`
  - `.cursor/rules/**`
- **Acceptance Criteria:**
  - All major roles (Cloudflare IaC, 1.00.ge, API, Frontend, QA, Observability, etc.) defined.
  - Each role has clear scope, allowed paths, and "must not" section.
- **Status:** ✅ Complete

**M0-T3 – Base CI pipeline**

- **Owner Agent:** CI/CD Agent
- **Description:** Create a minimal GitHub Actions workflow that:
  - Runs `npm test` (or `pnpm test`, configurable) if `package.json` is present.
  - Runs `npm run lint` if available.
- **Acceptance Criteria:**
  - Workflow under `.github/workflows/ci.yml`.
  - PRs show CI status checks.
  - No deployment yet.
- **Note:** Enabling branch protection on `main` typically requires manual configuration in GitHub settings (or via GitHub API/Terraform provider). The CI/CD Agent focuses on workflow files; you (as human/CTO) handle the branch protection toggle.
- **Status:** ✅ Complete

**M0-T4 – Cursor rules wiring**

- **Owner Agent:** Planner / CTO Copilot Agent
- **Description:** Ensure `.cursor/rules/*.mdc` exists and:
  - Loads `docs/AGENTS.md`.
  - Enforces per-folder behaviors (`infra/cloudflare`, `infra/100ge`, `apps*`, `tests`, etc.).
- **Acceptance Criteria:**
  - Opening files in different folders leads Cursor to adopt the right "agent" behavior.
  - A short explanation exists in `docs/DEVELOPING-WITH-CURSOR.md`.
- **Note:** Creating and updating Cursor rules is considered a documentation/planning task within the Planner / CTO Copilot Agent's scope, not something that requires other agents.
- **Status:** ✅ Complete

---

## Milestone 1 – Cloudflare Staging Baseline (Week 1–2)

**Objective:** A functioning staging environment for Escriturashoy on Cloudflare, all driven by Terraform + CI.

### Outcomes

- Cloudflare resources for staging declared in `infra/cloudflare`.
- A staging Pages project for `apps/public`.
- A staging Worker serving `api.escriturashoy.com` (or `api-staging.escriturashoy.com`).
- D1 DB, KV namespace, and R2 bucket provisioned.
- Terraform plan runs automatically in CI on PR.

### Tasks

**M1-T1 – Cloudflare Terraform baseline**

- **Owner Agent:** Cloudflare IaC Agent
- **Description:** Create Terraform modules/resources for:
  - Using existing `escriturashoy.com` zone (or a staging zone if preferred).
  - DNS CNAME/records:
    - `staging.escriturashoy.com` → Pages (public).
    - `api-staging.escriturashoy.com` → Worker route.
  - D1 database: `esh_staging`.
  - KV namespace: `ESH_CONFIG_STAGING`.
  - R2 bucket: `esh-docs-staging`.
- **Acceptance Criteria:**
  - `infra/cloudflare/main.tf` (or module pattern) compiles with `terraform validate`.
  - `terraform plan` shows resources for staging environment only.
  - No secrets in code.
- **Status:** ✅ Complete (INFRA-01 implemented)

**M1-T2 – Wrangler config & Workers skeleton**

- **Owner Agent:** Cloudflare IaC Agent + API & Workflow Agent
- **Description:**
  - Add `wrangler.toml` or per-app wrangler config for the API Worker.
  - Implement a minimal Worker in `apps-api/workers` with:
    - `/health` endpoint.
    - `/version` endpoint returning git SHA or static version.
- **Acceptance Criteria:**
  - Local dev with `wrangler dev` works.
  - Staging deploy possible via CI (even if manual for now).
- **Status:** ✅ Complete

**M1-T3 – Staging Pages project for marketing**

- **Owner Agent:** Cloudflare IaC Agent + Frontend UX / Flows Agent
- **Description:**
  - Configure Terraform for a Cloudflare Pages project for `apps/public`.
  - Implement a minimal landing page with:
    - Basic "Escriturashoy – Escrituras digitales en México" heading.
    - Placeholder sections for "Cómo funciona", "Seguridad y cumplimiento", "Contacto".
- **Acceptance Criteria:**
  - `staging.escriturashoy.com` (or similar) shows the minimal site.
  - Build pipeline in CI is green.
- **Status:** ✅ Complete

**M1-T4 – CI integration for Terraform and deploys**

- **Owner Agent:** CI/CD Agent
- **Description:**
  - Add GitHub Actions workflow to:
    - Run `terraform fmt` + `terraform validate` + `terraform plan` on PR.
    - On main branch merges, run `terraform apply` (with manual approval if needed).
    - Deploy Workers/Pages via wrangler/Pages CI.
- **Acceptance Criteria:**
  - Every infra PR shows a Terraform plan artifact.
  - Deployment to staging is traceable to CI runs.
- **Status:** ✅ Complete (Terraform CI workflow implemented)

---

## Milestone 2 – 1.00.ge Internal Infra & Observability (Week 2–3)

**Objective:** Have a secure internal environment on 1.00.ge with logging, observability, and Cloudflare Tunnel.

### Outcomes

- 1.00.ge VM(s) defined as code.
- Cloudflare Tunnel set up from `esh-log-01` to internal subdomain.
- Logs from Cloudflare (Logpush) flowing into R2 and ingested into 1.00.ge logging stack.
- Basic dashboards for API and Worker health.

### Tasks

**M2-T1 – 1.00.ge VM definition**

- **Owner Agent:** 1.00.ge Infra Agent
- **Description:**
  - Define at least one VM in `infra/100ge` (e.g., `esh-log-01`) with:
    - OS: Debian/Ubuntu LTS.
    - Basic hardening (SSH config, users).
  - Define network settings, internal-only where possible.
- **Acceptance Criteria:**
  - Terraform (or chosen tool) can provision the VM definition (even if manual apply).
  - No hardcoded credentials.
- **Status:** ⏳ Pending

**M2-T2 – Cloudflare Tunnel + Zero Trust access**

- **Owner Agent:** 1.00.ge Infra Agent + Cloudflare IaC Agent
- **Description:**
  - Install and configure `cloudflared` on `esh-log-01`.
  - Use Cloudflare Zero Trust app/tunnel to expose logs UI or Kibana at a private URL (e.g., `logs.internal.escriturashoy.com`).
  - Restrict access to your identity (SSO / email domain).
- **Acceptance Criteria:**
  - Access to logs UI is only possible via Cloudflare Access.
  - No direct public IP access.
- **Status:** ⏳ Pending

**M2-T3 – Logging pipeline from Cloudflare**

- **Owner Agent:** Observability & Alerts Agent + Cloudflare IaC Agent
- **Description:**
  - Configure Cloudflare Logpush for:
    - HTTP request logs for `staging.escriturashoy.com` and `api-staging.escriturashoy.com`.
  - Push logs to:
    - R2 bucket; from there, ingest to logging stack on `esh-log-01` (via cron or ETL process).
- **Acceptance Criteria:**
  - Logs from staging endpoints appear in the logging stack.
  - A simple dashboard shows request counts and 4xx/5xx rates.
- **Status:** ⏳ Pending

**M2-T4 – Basic alerts**

- **Owner Agent:** Observability & Alerts Agent
- **Description:**
  - Define an alert for:
    - API 5xx error rate exceeding threshold.
    - Worker CPU/time issues if metrics are available.
  - Document alert channels and expected response in `docs/OBSERVABILITY.md`.
- **Acceptance Criteria:**
  - At least one test alert has been triggered and documented.
  - There is a runbook in `docs/RUNBOOKS/monitoring-basic.md`.
- **Status:** ⏳ Pending

---

## Milestone 3 – App Skeletons & First Real Workflow (Week 3–5)

**Objective:** Have basic but real product scaffolding: marketing site, API, client/admin minimal UI, and one end-to-end "simple cash sale, no mortgage" flow.

### Outcomes

- `apps/public`: marketing + intake landing section.
- `apps/client`: minimal client dashboard (login, "Mi expediente", status).
- `apps/admin`: minimal backoffice view of expedientes.
- `apps-api/workers`: core routes and D1 schema for users, leads, and basic expedientes.
- Test coverage for the happy path of the first workflow.

### Tasks

**M3-T1 – Data model & migrations for core entities**

- **Owner Agent:** Data & Migration Agent
- **Description:**
  - Design and document schema in `db/schema/core.md` for:
    - `users`, `clients`
    - `leads`
    - `expedientes` (basic fields: id, client_id, property_location, type, status, created_at, updated_at)
  - Add initial migrations for D1 in `db/migrations`.
- **Acceptance Criteria:**
  - Migrations run successfully on staging.
  - ERD or schema diagram committed.
- **Status:** ✅ Complete

**M3-T2 – API endpoints for leads and expedientes**

- **Owner Agent:** API & Workflow Agent
- **Description:**
  - Implement Workers routes for:
    - `POST /leads` – intake.
    - `GET /expedientes/:id` – get status.
    - `GET /health` and `GET /version` already present from earlier.
  - Wire endpoints to D1 schema with basic validation.
- **Acceptance Criteria:**
  - Automated tests cover at least:
    - Create lead → stored in DB.
    - Fetch expediente (mocked or minimal real data).
- **Status:** ✅ Complete

**M3-T3 – Marketing site lead form**

- **Owner Agent:** Frontend UX / Flows Agent
- **Description:**
  - In `apps/public`, implement a lead capture form that:
    - Collects name, email/phone, property location, property type, and urgency.
    - Calls `POST /leads` on the staging API.
  - Show confirmation and "Próximos pasos" text.
- **Acceptance Criteria:**
  - End-to-end test validates lead creation via the form.
  - Basic responsive layout.
- **Status:** ✅ Complete

**M3-T4 – Client & admin skeletons**

- **Owner Agent:** Frontend UX / Flows Agent
- **Description:**
  - `apps/client`:
    - Simple login placeholder (even if backed by mock auth at first).
    - "Mis expedientes" page listing from a stub or API.
  - `apps/admin`:
    - Table of leads and expedientes.
    - Links to detail view (can be mocked/minimal).
- **Acceptance Criteria:**
  - Both apps build and deploy to staging (under different subpaths or subdomains).
  - Basic navigation and layout exist; no full functionality needed yet.
- **Status:** ✅ Complete

**M3-T5 – Tests & compliance checks**

- **Owner Agent:** QA & Compliance Agent + Policy & Security Guardian Agent
- **Description:**
  - Add tests for:
    - Lead form submission and basic validation errors.
    - API endpoints for leads.
  - Ensure:
    - Privacy and non-legal-advice disclaimers are visible on relevant pages.
  - Document legal/compliance assumptions in `docs/LEGAL-ASSUMPTIONS.md`.
- **Acceptance Criteria:**
  - CI passes all tests.
  - PRs adding user-facing flows are blocked if disclaimers are missing.
- **Status:** ✅ Complete

---

## Milestone 4 – Customer Support Agent & Deeper Workflows (TBD)

**Objective:** Expand platform capabilities with AI-powered support and complete expediente workflows.

### Outcomes

- Chat-based Customer Intake & Support Agent integrated into `apps/public`.
- More complete expediente workflows (KYC, docs, signing).
- Role-based admin flows.
- Production environment ready.

### Tasks

> To be fleshed out later. Will include:
> - Customer Intake & Support Agent integration
> - Complete expediente workflows (KYC, docs, signing)
> - Role-based admin flows
> - Production environment setup
> - Advanced observability and alerting

---

## Dependencies Graph

```
Milestone 0 (Repo & Governance)
    │
    ├──> Milestone 1 (Cloudflare Staging)
    │       │
    │       ├──> M1-T1 (Terraform) ──┐
    │       ├──> M1-T2 (Workers)     │
    │       ├──> M1-T3 (Pages)       ├──> M1-T4 (CI/CD)
    │       └──> M1-T4 (CI/CD)       │
    │
    └──> Milestone 2 (1.00.ge & Observability)
            │
            ├──> M2-T1 (VMs)
            ├──> M2-T2 (Tunnel) ──┐
            ├──> M2-T3 (Logging)   ├──> M2-T4 (Alerts)
            └──> M2-T4 (Alerts)    │

Milestone 1 + Milestone 2
    │
    └──> Milestone 3 (App Skeletons & First Workflow)
            │
            ├──> M3-T1 (Data Model)
            ├──> M3-T2 (API Endpoints)
            ├──> M3-T3 (Marketing Form)
            ├──> M3-T4 (Client/Admin UI)
            └──> M3-T5 (Tests & Compliance)

Milestone 3
    │
    └──> Milestone 4 (Advanced Features & Production)
```

---

## Risk Assessment

- **Cloudflare API Access:** Requires account setup and API tokens - mitigate by using CI secrets
- **1.00.ge Server Access:** Requires SSH/key management - mitigate by using Terraform/Ansible
- **Compliance Requirements:** Must meet NOM-151 and LFPDPPP - mitigate by early security review
- **State Management:** Terraform state must be secure and accessible - mitigate by using remote backend
- **Timeline Pressure:** Aggressive timeline may require scope adjustments - mitigate by prioritizing core workflows

---

## Status Legend

- ✅ Complete
- ⏳ Pending
- 🚧 In Progress
- ⚠️ Blocked

---

## Notes

- All tasks follow GitOps principles: changes via PR, no direct pushes to main.
- Agent assignments align with `docs/AGENTS.md` scope definitions.
- Timeline is indicative and should be adjusted based on team capacity and priorities.
- Security and compliance reviews should happen early and often, not just at the end.
