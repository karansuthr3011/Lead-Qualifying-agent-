# ASTRA FINAL HANDOFF

Authoritative lean context for the AI Real Estate Lead Conversion OS.

## Initial scope
- Source adapters: Meta Lead Ads, Website
- Communication/inbound channel: WhatsApp
- Future adapters: 99acres, MagicBricks, Housing.com, Google, CRM and other sources

## Core
Source adapter -> canonical lead event -> trusted tenant resolution -> idempotency -> lead state -> WhatsApp AI -> qualification -> policy -> action -> follow-up / site visit / human escalation. Postgres/Supabase is the durable source of truth.

## Critical audit gates
Trusted tenant before tenant-scoped writes; real Meta and Website adapter paths; actual tenant isolation; idempotency; human takeover; opt-out; stale-follow-up suppression; deterministic policy; no invented facts; demo=production architecture; honest live-verification status.

## Anti-overengineering lock
Do not add voice, dashboard, mobile app, billing, custom CRM, custom WhatsApp inbox, Kafka, Kubernetes, Redis, microservices, enterprise queueing, speculative integrations, or a large control plane unless a real client requirement, reproducible test failure, or credible security/data-loss risk proves it necessary.

## Reading order
ASTRA_FIRST_PROMPT.md -> MASTER_CONTEXT.md -> PRODUCT_RULES.md -> SOURCE_ADAPTER_CONTRACT.md -> current workflow JSON -> database-schema.sql -> tests -> references as needed.

## Honesty rule
Never infer that an integration, API, credential, database policy, or production behavior exists merely because documentation describes it.
