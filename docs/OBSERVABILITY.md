# Observability Documentation

## Overview

This document describes the observability strategy for Escriturashoy 2.0, including logging, metrics, tracing, and alerting.

## Logging

### Cloudflare Logpush

- **Source**: Cloudflare Workers, Pages, and edge requests
- **Destination**: Cloudflare R2 bucket
- **Format**: JSON logs
- **Retention**: TBD

### Log Aggregation

- **Pipeline**: R2 → 1.00.ge logging stack
- **Ingestion**: Automated via cron/ETL process
- **Storage**: Centralized logging stack on 1.00.ge VMs

### Log Levels

- **ERROR**: System errors, failed requests
- **WARN**: Warnings, degraded functionality
- **INFO**: General information, request logs
- **DEBUG**: Detailed debugging information (development only)

## Metrics

### Cloudflare Analytics

- Request counts
- Error rates (4xx, 5xx)
- Latency (p50, p95, p99)
- Worker CPU time
- Bandwidth usage

### Custom Metrics

- Business metrics (leads created, expedientes completed)
- Workflow metrics (time to completion, step durations)
- User activity metrics

## Dashboards

### API Health Dashboard

- Request rate
- Error rate
- Latency percentiles
- Worker performance

### Business Metrics Dashboard

- Leads per day/week/month
- Expediente status distribution
- Completion rates
- User activity

## Alerting

### Alert Rules

- **API Error Rate**: Alert when 5xx error rate exceeds threshold
- **Worker CPU**: Alert when CPU time exceeds limits
- **Latency**: Alert when p95 latency exceeds threshold
- **Availability**: Alert when service is down

### Alert Channels

TBD - Email, Slack, PagerDuty, etc.

## Tracing

Request tracing across Workers and services for debugging and performance analysis.

## Runbooks

See `docs/RUNBOOKS/` for operational runbooks related to observability and incident response.

