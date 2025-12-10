# Developing with Cursor

## Overview

This document explains how to use Cursor AI effectively with the Escriturashoy 2.0 codebase, leveraging the agent-based development model.

## Agent-Based Development

The codebase uses an agent-based development model where different AI agents have specific roles and scopes. See `docs/AGENTS.md` for complete agent definitions.

### Key Agents

- **Planner / CTO Copilot**: Roadmap and planning
- **Cloudflare IaC Agent**: Cloudflare infrastructure
- **1.00.ge Infra Agent**: Internal infrastructure
- **API & Workflow Agent**: Backend APIs
- **Frontend UX / Flows Agent**: Frontend applications
- **Data & Migration Agent**: Database schemas and migrations
- **QA & Compliance Agent**: Testing and compliance
- **Observability & Alerts Agent**: Monitoring and alerting

## Cursor Rules

Cursor rules are defined in `.cursor/rules/` and automatically apply based on the files you're working with:

- **`.cursor/rules/00-global.mdc`**: Global rules for all files
- **`.cursor/rules/01-escriturashoy.mdc`**: Escriturashoy-specific rules
- **`.cursor/rules/infra-cloudflare.mdc`**: Cloudflare infrastructure rules
- **`.cursor/rules/infra-100ge.mdc`**: 1.00.ge infrastructure rules
- **`.cursor/rules/apps.mdc`**: Frontend application rules
- **`.cursor/rules/apps-api.mdc`**: API/Workers rules
- **`.cursor/rules/tests.mdc`**: Testing rules

## Using Agents in Cursor

### Explicit Agent Activation

When you want to work as a specific agent, say:

```
"Act as the Cloudflare IaC Agent and implement M1-T1"
```

Cursor will:
1. Read `docs/AGENTS.md` to understand the agent's scope
2. Focus on the appropriate files (e.g., `infra/cloudflare/**`)
3. Follow the agent's constraints (what it can and cannot do)

### Automatic Agent Selection

Cursor automatically selects the appropriate agent based on:
- Files you're editing
- Directory structure
- Cursor rules

For example:
- Editing `infra/cloudflare/*.tf` → Cloudflare IaC Agent
- Editing `apps/public/**` → Frontend UX / Flows Agent
- Editing `apps-api/workers/**` → API & Workflow Agent

## Best Practices

### 1. Read Documentation First

Before making significant changes:
- Read `docs/AGENTS.md` to understand agent scopes
- Read `docs/ROADMAP.md` to understand current priorities
- Read `docs/ARCHITECTURE.md` to understand system design

### 2. Follow Agent Scopes

- Don't modify files outside your agent's scope
- If you need changes in another scope, ask the appropriate agent
- Respect the "Must NOT" constraints for each agent

### 3. Use GitOps Workflow

- All changes via Pull Requests
- Never push directly to `main`
- Create feature branches
- Submit PRs with clear descriptions

### 4. Clarify Ambiguity

If a task is ambiguous:
1. Restate your understanding
2. Propose a minimal plan
3. Then start implementing

### 5. Update Documentation

When adding features:
- Update `docs/ARCHITECTURE.md` if architecture changes
- Update `docs/DATA-MODEL.md` if data model changes
- Update `docs/OBSERVABILITY.md` if observability changes
- Add ADRs in `docs/ADR/` for significant decisions

## Common Workflows

### Adding a New Feature

1. Check `docs/ROADMAP.md` for priorities
2. Identify which agent(s) should work on it
3. Create a feature branch
4. Make changes following agent scopes
5. Add tests (QA & Compliance Agent scope)
6. Update documentation
7. Submit PR

### Modifying Infrastructure

1. Act as Cloudflare IaC Agent or 1.00.ge Infra Agent
2. Modify Terraform files
3. Run `terraform plan` locally
4. Submit PR (CI will run `terraform plan`)
5. After merge, CI will apply changes

### Adding API Endpoints

1. Act as API & Workflow Agent
2. Modify `apps-api/workers/**`
3. Update database schema if needed (coordinate with Data & Migration Agent)
4. Add tests
5. Update API documentation
6. Submit PR

## Troubleshooting

### Cursor Not Following Agent Rules

- Check that `.cursor/rules/` files exist
- Verify rules reference `docs/AGENTS.md`
- Explicitly state which agent to use

### Unclear Scope

- Read `docs/AGENTS.md` for agent definitions
- Ask which agent should handle the task
- Break down the task into agent-specific subtasks

## Resources

- **Agent Definitions**: `docs/AGENTS.md`
- **Roadmap**: `docs/ROADMAP.md`
- **Architecture**: `docs/ARCHITECTURE.md`
- **Cursor Rules**: `.cursor/rules/`

