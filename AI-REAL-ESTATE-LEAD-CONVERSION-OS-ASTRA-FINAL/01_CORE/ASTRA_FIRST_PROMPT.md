# ASTRA BUILD INSTRUCTION

Read ONLY the files in this repository plus the current workflow and the two reference automations.

DO NOT start coding immediately.

FIRST:
1. Read `01_CORE/MASTER_CONTEXT.md`
2. Read `01_CORE/PRODUCT_RULES.md`
3. Read `01_CORE/SOURCE_ADAPTER_CONTRACT.md`
4. Inspect `02_CURRENT_WORKFLOW/AI_REAL_ESTATE_LEAD_CONVERSION_OS_CURRENT.json`
5. Inspect `04_DATABASE/database-schema.sql`
6. Read `05_TESTING/test-cases.md`
7. Inspect both raw reference workflows in `03_REFERENCE/`
8. Read `03_REFERENCE/REFERENCE_PATTERNS.md`

Then produce `AUDIT.md` only.

AUDIT MUST:
- identify what the current workflow actually does
- identify real P0 blockers
- identify already-fixed historical issues
- identify test-only unknowns
- confirm demo -> production parity
- confirm how a future 99acres adapter plugs into the same core
- use evidence from files, not assumptions

DO NOT:
- redesign the product
- add voice/dashboard/frontend/CRM/inbox
- invent external APIs
- claim live testing
- reintroduce historical FastAPI/Redis/Kafka/Kubernetes architecture
- build 99acres now
- rewrite working workflow for aesthetics

After the audit, stop.


## NON-NEGOTIABLE INITIAL SOURCE SCOPE
Implement and verify only Meta Lead Ads, Website, and the WhatsApp communication/inbound channel. Do not implement future portals, voice, dashboard, custom CRM, custom inbox, billing, or enterprise infrastructure unless a real requirement, reproducible test failure, or credible security/data-loss risk proves it necessary.

## AUDIT GATES
Before declaring complete, verify: trusted tenant resolution before tenant-scoped writes; real Meta and Website adapter paths; actual tenant-isolation policies; event/message idempotency; human takeover; opt-out enforcement; stale-follow-up suppression; deterministic policy before actions; no invented project facts; demo equals production architecture; and no unsupported live-verification claims. Fix concrete implementation gaps while preserving the architecture.
