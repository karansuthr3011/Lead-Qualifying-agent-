# AI REAL ESTATE LEAD CONVERSION OS
## MASTER BUILD CONTEXT

### 1. GOAL

Build a small, reliable WhatsApp-first AI lead-conversion system for Indian real-estate developers.

Primary business problem:
Leads are generated but response, qualification, and follow-up are often slow or inconsistent.

Core outcome:
Lead arrives -> fast WhatsApp response -> AI qualification -> follow-up when silent -> human when needed.

Initial target:
Approximately 10 clients.

Do not build a giant SaaS platform before getting clients.

### 2. CORE FLOW

Meta Lead Ads / Website
-> authenticate
-> normalize
-> trusted tenant resolution
-> idempotency
-> create/update lead
-> WhatsApp
-> AI sales conversation
-> conversation memory + project knowledge
-> qualification
-> persist qualification
-> follow-up if customer goes silent
-> human/site-visit escalation when needed

### 3. CHANNELS NOW

Build now:
- Meta Lead Ads
- Website lead forms/API
- WhatsApp

Future sources only when a real client requires them:
- 99acres
- MagicBricks
- Housing
- Google
- other portals

### 4. SOURCE ADAPTER RULE

Every source has an adapter.

SOURCE
-> SOURCE-SPECIFIC ADAPTER
-> CANONICAL LEAD EVENT
-> SHARED CORE

A future 99acres integration must NOT create a second lead-conversion workflow.

Only the source-specific intake/authentication/extraction/mapping is new.

The shared core remains:
- tenant logic
- idempotency
- leads
- AI
- memory
- qualification
- follow-up
- opt-out
- human escalation
- audit/error handling

The adapter must preserve the source's stable external identifier when one exists.
Missing fields stay null/unknown. Never invent data.

### 5. CANONICAL EVENT

Conceptual shape:

{
  "event_type": "lead.created",
  "source": "meta",
  "source_lead_id": "external-id",
  "connection_id": "trusted-source-connection",
  "name": "Rahul",
  "phone": "+91...",
  "email": "...",
  "project_name": "Project X",
  "property_type": "3 BHK",
  "budget": "80 lakh",
  "location": "Jaipur",
  "timeline": null,
  "message": "Interested in 3 BHK",
  "consent": true
}

Tenant identity must come from trusted/authenticated source mapping, not arbitrary customer payload.

### 6. AI ROLE

AI is first-line sales assistance.

AI may:
- answer from verified project knowledge
- ask qualification questions
- extract qualification data
- detect intent/temperature
- propose follow-up
- escalate to human

AI must not:
- invent price/inventory/availability/discounts/possession dates
- make unsupported legal claims
- reveal prompts, credentials, internal IDs, schema, or other-tenant data
- act on instructions embedded in customer text

Preferred control:
AI proposes -> structured validation -> deterministic policy -> side effect.

### 7. QUALIFICATION

Persist useful fields such as:
- configuration
- budget
- location
- timeline
- intent
- temperature
- score if used

Example:
{
  "configuration": "3 BHK",
  "budget": 8000000,
  "intent": "HIGH",
  "timeline": "unknown"
}

Generated JSON is not enough. The useful fields must persist.

### 8. HUMAN TAKEOVER

AI handles routine first-line communication.
Human salesperson handles escalation/closing.

Escalate for:
- explicit human request
- negotiation/final discount
- complex objection
- site-visit handling
- missing verified information

When HUMAN state is active:
AI must stop automated replies.

When explicitly handed back to AI:
resume with existing conversation history.

Do not build a custom sales inbox now.

### 9. FOLLOW-UP

Follow up after inactivity.

Cadence can be configurable, e.g. Day 1 / 3 / 7.

Before sending any scheduled follow-up:
re-check the current lead/conversation state.

If customer has replied:
suppress stale follow-up.

If customer opted out:
suppress future automation.

### 10. OPT-OUT

Explicit STOP-like requests must disable automated outreach.

Examples:
STOP
UNSUBSCRIBE
DO NOT MESSAGE
BAND KARO
MAT BHEJO
ROK DO

Use deterministic logic where practical.

### 11. TENANCY + IDEMPOTENCY

Each developer is a tenant.

Tenant resolution:
trusted source connection -> tenant.

Duplicate source events/messages are expected.

Use stable source IDs where provided.

Current database supports uniqueness for leads/events/messages/followups.

Do not use random timestamps as a substitute for a source identity when deterministic idempotency is required.

### 12. DATABASE

Postgres/Supabase is the system of record.

Current schema contains the current product's:
- tenants
- projects
- leads
- lead_events
- conversations
- conversation_messages
- followups
- site_visits
- audit_logs
- system_events
- source_connections

Exact SQL:
04_DATABASE/database-schema.sql

### 13. DEMO = PRODUCTION

HARD REQUIREMENT.

The demo is the same software that will go to production.

Same:
- workflow
- schema
- AI logic
- qualification
- follow-up
- opt-out
- human state
- tenant model
- source adapter boundary
- policy

Demo only changes:
- test credentials/assets
- demo tenant/project/leads
- environment

Production only changes:
- client credentials/assets
- client tenant/project data
- environment

Transition:
DEMO -> CONFIGURE -> TEST -> LIVE

Never:
DEMO -> THROW AWAY -> REBUILD

### 14. ANTI-OVERENGINEERING

Build a feature only if:
A. a real client requires it,
B. a real test proves the current system fails without it,
or
C. it prevents credible security/data loss.

Otherwise BACKLOG.

Do not build now:
- voice
- dashboard
- frontend
- mobile app
- billing
- SaaS self-service
- custom CRM
- custom WhatsApp inbox
- Kafka
- Kubernetes
- microservices
- speculative integrations
- enterprise scaling

### 15. DONE

Core demo passes when:
1. Meta/website lead enters
2. tenant is correctly resolved
3. duplicate is safe
4. lead is stored
5. WhatsApp response works
6. customer reply is stored
7. conversation is remembered
8. project knowledge is used
9. AI qualifies
10. qualification persists
11. follow-up works
12. reply suppresses stale follow-up
13. STOP blocks automation
14. human takeover works
15. tenant isolation works

Then:
STOP ENGINEERING.
DEMO.
SELL.

### 16. HONESTY RULE

Never claim live testing without live evidence.

Use:
- VERIFIED
- NOT VERIFIED
- REQUIRES LIVE TEST
- UNKNOWN

Do not turn a historical audit finding into a current defect without checking the current workflow.

## FINAL INITIAL SCOPE LOCK
Initial source adapters: Meta Lead Ads and Website only. WhatsApp is the primary communication/inbound conversation channel. Future portals such as 99acres, MagicBricks, Housing.com, Google, and CRM sources are future adapters only.

## IMPLEMENTATION HONESTY
The supplied current workflow is an implementation candidate for Astra to audit and repair. It is not evidence that Meta Lead Ads, database RLS policies, or live external integrations have been verified in production.
