AI Real Estate Lead Conversion OS — implementation audit

Date: 2026-09-19

1. Decision and scope

NOT READY for the required demo or production. The supplied workflow contains reproducible core-flow defects and credible authorization/state risks. This is an audit of the supplied implementation, not a live deployment certification.

ASTRA_FIRST_PROMPT.md is the primary instruction, as requested. It explicitly says “Then produce AUDIT.md only” and “After the audit, stop.” The chat and earlier pasted request also ask for an audit → fix → test → repair cycle. This deliverable honors the explicit primary audit gate: no implementation repairs, migrations, credential changes, architecture changes, or deployments were performed. Isolated checks below establish audit evidence, not a completed repair cycle.

The architecture remains n8n + Postgres/Supabase + the supplied AI integration + WhatsApp. No Next.js application work, replacement agent framework, frontend, future portal adapter, or speculative feature was introduced.

Evidence vocabulary

VERIFIED: directly established from the supplied files or an executed local check; the scope is stated.

NOT VERIFIED: not established end-to-end.

REQUIRES LIVE TEST: requires the configured n8n/database/provider environment.

UNKNOWN: missing evidence or runtime-dependent behavior.

Test outcomes use PASS / FAIL / NOT RUN / BLOCKED. A local PASS is not a provider or production PASS.

2. What was inspected

The eight newly attached implementation/context files were read, along with the prior handoff, request, manifest, and hashes:

ASTRA_FIRST_PROMPT.md

MASTER_CONTEXT.md

PRODUCT_RULES.md

SOURCE_ADAPTER_CONTRACT.md

AI_REAL_ESTATE_LEAD_CONVERSION_OS_CURRENT.json: all 1,711 lines, including nodes, connections, settings, and credential references.

database-schema.sql

demo-test-data.json

test-cases.md

ASTRA_FINAL_HANDOFF.md, REPOSITORY_MANIFEST.md, FILE_HASHES_SHA256.txt, and the earlier pasted 59-line request.

The full workflow JSON parsed successfully. Its embedded migration was compared programmatically with the standalone SQL, ignoring comments/whitespace; they match. This also checked the complete embedded SQL string, which exceeds the file viewer's single-line display limit.

Integrity checks

The following attached files match their supplied SHA-256 manifest entries:

File

Verified SHA-256

Current workflow

dbf52e4ab6bdf36b5e27f947de6124bea7b117fde97d580423ccad30bc863e71

Database schema

0463ca180935aec4158da01779778d5279edd985099d43256fd5bcf44ad885e9

Demo fixture

23e3b9a0d04b086cad1ed31b4d4ad2608fd1cdff616a9d1197678abb6a5eb5b9

These hashes establish consistency with the supplied manifest, not provenance or security certification. Other attachment hashes were not checked.

Missing materials

The attachment inventory still does not contain either raw reference workflow or 03_REFERENCE/REFERENCE_PATTERNS.md:

AI Lead Gen Machine v6 - Reply Aware (1) (2)(2).json

AI Real Estate Marketing Kit — Full System (3)(2).json (the manifest title also has a house symbol)

REFERENCE_PATTERNS.md

The database/output READMEs and ENVIRONMENT_VARIABLES.example are also not attached. A workflow README is listed in the hashes but not in the repository manifest or attachments.

Reference comparison is BLOCKED. No reference patterns or historical implementation details were invented. This does not prevent identifying defects in the actual supplied workflow, but the primary instruction's full reference-reading gate is not complete.

3. What the current workflow actually does

VERIFIED from the JSON: 51 nodes, 50 connection edges, 11 JavaScript Code nodes. All edge endpoints exist, all node IDs are unique, and the 11 code snippets compile as JavaScript. The export is active: false, uses Asia/Kolkata, has a 120-second execution timeout, and has placeholder Postgres/OpenAI credential references.

Initialization

A manual trigger runs DB — Schema Migration. It creates 11 application tables, indexes, a demo tenant, and placeholder WhatsApp/internal source connections. It does not seed the demo project/lead fixture. Existing-table upgrades rely on CREATE TABLE IF NOT EXISTS, not a versioned repair migration.

Inbound path

INBOUND — All Lead Sources declares GET/POST and raw-body handling.

Webhook — GET Verification? checks the subscription query and verification token, then returns the challenge; the other branch goes to request verification.

Security — Verify Request verifies an HMAC when possible, or hashes any presented internal API key and defers lookup. It derives a WhatsApp phone-number selector from the body.

Webhook — Return Accepted returns OK before database-backed authorization, durable event recording, or processing.

Normalize — Canonical Lead Event emits a flat event.

Critically, normalization fans out to both the business-event router and tenant resolution. The intended protected branch is connection lookup → resolved tenant → event insert → reattach → the same business router.

The business router handles lead creation, WhatsApp messages, site-visit booking/outcome, or unknown-event logging.

Lead/conversation/AI path

Lead creation upserts a lead and invokes the AI context builder.

WhatsApp processing attempts STOP detection, lead lookup by phone, message reattachment, and inbound conversation logging before AI.

The agent has a Postgres chat-memory node, three read-only SQL tools, an OpenAI chat model, and a structured-output parser.

A code parser validates the action name, coerces score/message, then policy produces an allowed decision.

A database audit node precedes the action switch.

Actions include a WhatsApp text send, follow-up scheduling, lead opt-out, site-visit-request status, and an escalation email.

Only the RESPOND switch output sends a message. FOLLOW_UP schedules another job; it is not itself a send action.

Follow-up/error paths

Every 10 minutes the worker claims up to 25 due rows using FOR UPDATE SKIP LOCKED, marking them PROCESSING.

It loads a lead, reattaches job identity, and invokes the AI agent.

No job-completion, cancellation, retry/recovery, or lease-expiry path appears in the workflow.

An error trigger connects to a system-event insert. The settings do not show an explicit errorWorkflow binding; actual error-trigger wiring is UNKNOWN, not proven operational by the presence of a node.

4. P0 blockers — authorization and automation safety

P0 here means a release-blocking risk to trusted tenant handling, suppression controls, or core delivery reliability. Proposed corrections describe the smallest repair boundary; they have not been implemented.

P0-01 — Business routing bypasses tenant resolution and idempotency

Evidence: workflow connections, lines 1224–1237: Normalize — Canonical Lead Event connects directly to Route — Lead Created? as well as Resolve Tenant — By Connection. The guarded path later reconnects to the same router at lines 1662–1671.

VERIFIED: a graph assertion requiring no direct bypass failed. Normalization does not include tenant_id, so the unguarded branch can attempt tenant-scoped operations without a resolved tenant. With the supplied NOT NULL constraints this can fail, rather than necessarily succeed as a cross-tenant write. Branch scheduling and whether that failure prevents the protected branch require n8n execution. Either outcome violates the required order.

Minimal repair boundary: make authentication → trusted connection/tenant → canonical validation/idempotency the sole path to business routes. Test graph reachability as well as actual tenant-scoped writes.

P0-02 — An unverified key can select a WhatsApp connection

Evidence: Security — Verify Request (line 63) accepts any nonempty internal key as internal_key_presented, while also extracting _phone_number_id from its body. Resolve Tenant — By Connection (lines 1014–1016) matches (provider='whatsapp' AND external_account_id=$1) OR (provider='internal' AND api_key_hash=$2) without tying the branch to the verified authentication method.

VERIFIED locally: an invalid key with a body containing KNOWN_ACCOUNT produced both _auth_method: 'internal_key_presented' and _phone_number_id: 'KNOWN_ACCOUNT'. The SQL's WhatsApp branch can match that account independently of the wrong hash. Database exploitation was not attempted. With an existing matching source connection, the predicate admits an unauthorized tenant selection.

The lookup also lacks tenant-status checking and returns only a tenant ID, losing the authenticated connection/provider identity needed to authorize subsequent event types. An untrusted source/event_type remains caller-selectable.

Minimal repair boundary: bind each lookup to its successfully verified auth method and provider, reject mismatches, enforce active tenant/connection and event permissions, and retain trusted connection identity. Do not acknowledge an unauthorized request as accepted.

P0-03 — Tenant isolation is not implemented as an executable database policy contract

Evidence: standalone SQL and matching embedded migration enable RLS on ten tables but contain no CREATE POLICY statements. source_connections has neither RLS enablement nor policies. No app role, grants, transaction-local tenant context, or matching policy is supplied. Foreign keys such as leads.project_id and child lead_id/conversation_id reference IDs alone, not tenant-and-ID pairs.

VERIFIED statically: no tenant policies; source-connection RLS missing. Enabling RLS without policies is default-deny for ordinary roles, not evidence of an automatic cross-tenant read leak. Owners/BYPASSRLS roles can bypass it. The actual n8n role and privileges are UNKNOWN. Thus the current package establishes neither working tenant access under a restricted role nor enforced isolation for a privileged role.

Cross-tenant references remain structurally possible if an authorized/privileged writer supplies inconsistent tenant and foreign IDs. The implicit Postgres chat-memory table is not declared in this migration, so its privileges/isolation are also unknown.

Minimal repair boundary: specify the least-privilege runtime and trusted resolver/worker access model within the existing Postgres architecture; implement tenant policies/context and tenant-consistent references; test two tenants using the real application role, not just an owner. Avoid assuming RLS protects owner/service-role access.

P0-04 — STOP and human takeover are not deterministic safety barriers

Evidence:

WhatsApp — Parse (line 199) produces stop, but no deterministic route/policy consumes that flag before the agent.

Policy — Security + Business Rules (line 396) blocks only OPTED_OUT, BOOKED, and LOST; it does not block HUMAN.

STOP-like DO NOT MESSAGE is absent from the regex, although required by the master context.

Action — Human Escalation sends email but does not persist HUMAN ownership, cancel jobs, or provide authenticated hand-back.

STOP_AUTOMATION and ESCALATE_HUMAN overwrite an earlier missing_identity denial with allowed=true.

The escalation switch condition (line 528) omits policy.allowed entirely.

VERIFIED locally: STOP itself was recognized; DO NOT MESSAGE was not. A HUMAN lead with a RESPOND proposal was allowed. A stop:true input with a RESPOND proposal was allowed. Escalation with no tenant/lead identity was allowed.

Minimal repair boundary: persist opt-out/human ownership before model invocation; enforce identity and state without unconditional overrides; cancel/suppress jobs; gate all effects, including escalation; add a trusted hand-back transition retaining history. Explicit human requests must not depend solely on model interpretation.

P0-05 — Stale follow-ups and state changes are not checked at the send boundary

Evidence: Follow-up — Claim Due excludes several terminal states but not HUMAN. The worker loads a lead once, then asks the AI to re-read state in text. The policy does not compare latest inbound activity against the scheduled follow-up. The inbound path does not invalidate pending jobs. Action — WhatsApp Send performs no final state/message-version check. Action — Opt Out changes lead state but does not cancel pending/processing work.

VERIFIED from the graph/SQL: no deterministic reply watermark or current-state send gate exists. A prompt to re-read state is not such a gate. Already-claimed work can outlive a reply, opt-out, or takeover. No actual race was run against Postgres/provider services.

Minimal repair boundary: track the inactivity basis in existing durable state, invalidate stale jobs on inbound/state changes, and re-check tenant, consent, ownership, opt-out, and reply freshness immediately before authorizing a send. Document handling of a state change after external dispatch has already begun; do not claim a database transaction can retract an already-sent provider message.

P0-06 — Durable acknowledgement/retry boundaries can lose work or duplicate sends

Evidence: acceptance precedes durable authorization/recording. Idempotency — Record Event inserts a unique event and commits in a separate node before lead/action processing, with no processing/completion state or recovery path. HTTP send retries three times, but outbound messages do not persist the returned provider message ID or a stable send-intent identity. Follow-ups are set to PROCESSING with no later terminal/recovery update.

VERIFIED statically: a failed execution after event insertion has no supplied resumption mechanism; a replay conflicts with the recorded event. A provider timeout after actual delivery can be retried without a recorded outcome. Jobs can remain PROCESSING indefinitely. These are credible delivery loss/duplication risks, not claims that a live duplicate was observed.

Minimal repair boundary: repair durable event/job status and retry semantics in the existing database/workflow; acknowledge only after authorized durable acceptance; reconcile uncertain sends rather than blindly resending; retain provider response IDs. No external queue infrastructure is necessary to establish this repair requirement.

P0-07 — Outbound credentials and escalation destination are global, not tenant-bound

Evidence: Action — WhatsApp Send uses global RE_WHATSAPP_PHONE_NUMBER_ID and RE_WHATSAPP_ACCESS_TOKEN; human escalation uses global sales-email environment values. Inbound mapping supports multiple tenants, but the outbound path neither selects nor checks a trusted tenant-specific channel/destination.

VERIFIED configuration shape: multiple tenant rows in this single configured workflow would use the same sender and escalation recipient. No live misdelivery was attempted. A documented single-tenant deployment boundary could alter the risk, but none is supplied and it would not itself verify the stated reusable multi-tenant core.

Minimal repair boundary: tie outbound sender/credential selection and human notification routing to the same trusted tenant configuration, without copying the core into per-source workflows or exposing tokens in events/model context.

5. Additional core-demo blockers and correctness defects

C-01 — Native Meta Lead Ads adapter is missing

There is no leadgen extraction, stable leadgen_id handling, page/form connection mapping, or lead-detail lookup node. The only HTTP request node is the WhatsApp send. The source-provider check permits whatsapp, internal, and website, not meta. A HMAC-capable generic endpoint and a synthetic lead whose source is meta do not constitute a Meta adapter.

Status: VERIFIED missing implementation; T01 cannot pass for a native Meta notification. Exact external API configuration and access remain REQUIRES LIVE TEST. Do not invent provider endpoints from this audit.

C-02 — Website normalization destroys phones and does not resolve website credentials

Normalize — Canonical Lead Event contains an over-escaped phone regex. Executing it with the supplied fixture phone +919876543210 returns +. The resolver searches only internal/WhatsApp connections even though the schema allows website.

Missing stable IDs become evt_/lead_ timestamp identifiers. Missing facts become empty strings rather than null/unknown; lead upsert uses COALESCE, so empty strings can overwrite stored values. Required-field/event-shape validation is absent.

Status: VERIFIED local mapping failures and source-resolution mismatch. A generic flat Website payload through an internal key is only a partial path, not the tested Website adapter contract.

C-03 — Native WhatsApp messages are not extracted

Security reads the first metadata phone-number ID, but normalization never extracts value.messages[*].from, .id, or .text.body. An isolated signed envelope containing STOP produced empty phone, message, and external-message ID. Entries/changes/messages are not iterated; delivery statuses and non-text message behavior are undefined.

WhatsApp — Reattach Lead + Message spreads normalized message fields over the stored lead, overwriting stored consent with the default false and phone with an empty string. That exact overwrite was reproduced locally. This can block legitimate replies, independent of the already-broken native payload extraction.

Status: VERIFIED local failures. Real raw-body representation and webhook subscriptions remain REQUIRES LIVE TEST.

C-04 — Project binding and qualification persistence are absent

Normalization does not retain fixture project_id; it emits a project string, but Lead — Upsert neither resolves nor writes project_id. The project-knowledge tool correctly joins through leads.project_id, so ordinary newly ingested leads cannot reach the supplied project facts without an external binding not implemented here.

No workflow SQL persists AI temperature, score, intent, configuration, budget, location, or timeline after qualification. Intake fields are not a substitute for persisting subsequent conversational qualification. The structured output shape has no configuration/budget/location/timeline extraction fields.

Status: VERIFIED missing persistence/binding. Project-knowledge grounding and successful qualification cannot be claimed.

C-05 — AI output contract and context hand-off are incomplete

AI — Structured Output puts a JSON Schema document into jsonSchemaExample without an explicit manual-schema selection. Whether the installed n8n parser interprets this as an example or schema must be checked in the actual n8n version; the export alone does not establish enforcement.

AI — Parse Output checks action and parseable JSON but coerces scores, truncates message, and fails to validate required keys, enum values, number bounds/types, or extra fields. An object containing invalid temperature/intent, a nonnumeric score, and negative hours was accepted locally; score became zero.

The parser does not restore authoritative identity/state from the pre-agent context. With a simulated output-only agent item, tenant/lead identity is absent. Audit — Decision executes an INSERT without RETURNING context, yet the switch expects $json.policy/$json.agent. The HTTP response similarly precedes a logger that expects the pre-send context. These expression dependencies are concrete; the exact n8n output envelopes/passthrough behavior are NOT VERIFIED, not represented as an executed end-to-end failure.

Minimal repair boundary: strict manual schema plus deterministic validation, explicit reattachment of authoritative context at output boundaries, and fail-closed routing.

C-06 — Conversation uniqueness/history and event identity are incomplete

Both inbound/outbound logging insert a conversation with ON CONFLICT DO NOTHING, but no unique (tenant_id, lead_id, channel) constraint exists. Random UUID primary keys will not conflict for repeated logical conversations. The history tool selects only the latest conversation, potentially fragmenting prior WhatsApp history.

Message uniqueness exists, but native WhatsApp IDs are never extracted. Empty-string IDs can collide; null IDs would bypass uniqueness. Outbound insert does not store provider IDs. Event uniqueness omits source/connection, so identical external IDs across sources in one tenant can collide. Stable source IDs are preserved only when a supported top-level field is supplied; otherwise timestamp generation defeats deterministic deduplication.

Minimal repair boundary: establish one intended conversation identity, preserve provider IDs, and namespace canonical event IDs by trusted source/connection as required by the actual source contract.

C-07 — Scheduler batching can discard claimed jobs

The claim query returns up to 25 rows. Follow-up — Reattach Context uses $input.first() and returns one item, with no explicit per-item mode. Several other Code nodes use the same pattern. Under the default all-items Code-node mode this discards all but the first input; the other claimed jobs then remain PROCESSING.

Status: VERIFIED first-item-only code/absent explicit mode; n8n batching and linked-item semantics require runtime reproduction. Completion/recovery absence is independently VERIFIED.

C-08 — SQL parameter transport is fragile and requires n8n verification

Nineteen nodes serialize queryReplacement with .join(','); nested JSON payloads and ordinary messages contain commas, and nulls become empty fields. The isolated expression check confirms a string rather than a parameter array. Queries do use $1 placeholders: this is not proof of SQL injection, and actual splitting/conversion depends on the n8n Postgres node version.

Minimal repair boundary: use the supported typed parameter-array mechanism and test commas, quotes, nulls, booleans, nested JSON, and multiline input against the actual node. Do not assert successful parameterization solely because placeholders appear in SQL.

C-09 — Site-visit control payload loses identity

Normalization emits source_lead_id but not the internal lead_id that Visit — Book expects. Booking inserts before the guarded lead-status update, without tenant-and-lead validation in that insert. The update excludes OPTED_OUT but does not preserve HUMAN. Outcome accepts an arbitrary outcome string. Replay protection depends on the currently flawed event boundary; no independent visit event identity is recorded on the visit.

This is existing functionality to repair, not a reason to add a booking product or new UI.

C-10 — “No invented facts” is currently an instruction, not demonstrated behavior

The system prompt correctly forbids invented project facts and asks for escalation when verified information is missing. Tools are read-only and tenant/lead filtered. However, project binding is absent on intake, tool use is optional, and no deterministic check requires verified knowledge/provenance before factual messages are sent.

Status: intent VERIFIED; compliance NOT VERIFIED. Missing-knowledge, adversarial customer-text, invented price/inventory, and cross-tenant disclosure tests are required. Do not label the model safe solely from its prompt.

6. Existing safeguards — do not mislabel these as wholly absent

The historical reference workflows/audits are missing, so historical “fixed” status is UNKNOWN. These mechanisms are demonstrably present in the current candidate and should be preserved while repairing their wiring/coverage:

Present mechanism

Evidence

Limitation

Explicit source-connection tenant lookup

Resolve/Attach nodes

Direct routing bypass and auth-method confusion remain

Arbitrary payload tenant ID not copied by canonical normalizer

Normalizer explicit output fields

This alone does not fix spoofable connection selection

Event uniqueness and conflict suppression

lead_events unique key and insert

Timestamp fallback, source collisions, bypass, and recovery remain

Lead/message uniqueness

SQL unique constraints

Native IDs/mapping and logical conversation identity remain broken

Inbound message logging

Conversation nodes

Native extraction, parameter transport, history fragmentation remain

Named read-only scoped AI tools

Three SQL tools

Project binding/runtime role/context must work

Database-backed chat-memory node

Tenant+lead session key

Implicit table, batching, and actual history continuity unverified

Action allowlist and malformed-JSON rejection

Parse Output

Full structured validation absent

Consent/phone and some status checks

Policy

HUMAN/STOP/freshness/identity overrides remain

Decision audit node

Audit Decision

Data continuity and error behavior unverified

Follow-up claim locking

FOR UPDATE SKIP LOCKED

No completion/recovery or final send-state check

One pending follow-up index/upsert

SQL plus schedule action

Does not cover processing recovery

GET challenge branch/HMAC code/size guard

Webhook and Security nodes

Raw-body fidelity, late size check, and auth fallback need verification

Unknown-event and error-log nodes

System-event inserts

Durability/wiring/parameter transport unverified

RLS enabled on ten tables

Schema

No actual tenant policies; not enabled for source connections

These are partial safeguards, not evidence that corresponding acceptance tests pass.

7. Checks actually executed

Checks ran locally in Node using the unchanged workflow's actual code strings in isolated VM contexts and static graph/SQL assertions. Temporary copies of the read-only workflow, schema, and fixture were used for execution, then removed. No n8n instance, Postgres queries, model calls, provider requests, migrations, or external mutations were executed.

Two diagnostic runs evaluated 40 assertions: 15 PASS, 25 FAIL. These include static contract checks and simulated node-boundary inputs, not 40 end-to-end tests. The diagnostic runner printed failures but exited zero; that exit code is not a green acceptance result.

Run A — graph and isolated Code nodes (6 PASS, 13 FAIL)

Check

Result

Observed evidence

Edge references resolve

PASS

51 nodes / 50 edges

Node IDs unique

PASS

No duplicate identifiers

Code-node syntax

PASS

11 snippets compile

No pre-tenant route bypass

FAIL

Direct normalizer → business router edge

Website phone preserved

FAIL

+919876543210 → +

No generated timestamp identity fallback

FAIL

evt_ / lead_ fallbacks

Missing facts stay null

FAIL

Name/email become empty strings

Invalid key cannot select WhatsApp account

FAIL

Invalid-key auth retained supplied account selector

Native WhatsApp body/from/id extraction

FAIL

All three canonical fields empty

STOP recognition

PASS

stop: true

DO NOT MESSAGE recognition

FAIL

stop: false

HUMAN blocks RESPOND

FAIL

allowed: true

STOP flag overrides RESPOND

FAIL

allowed: true

Escalation preserves missing-identity denial

FAIL

allowed: true

Invalid structured fields rejected

FAIL

Invalid enum/hours accepted; score coerced to 0

Malformed JSON rejected

PASS

Parser throws

Unknown AI action rejected

PASS

Parser throws

Output-only agent result restores identity

FAIL

No tenant/lead identity restored; simulated boundary

Reattachment preserves stored consent

FAIL

Stored true overwritten with false

Run B — schema, integrity, and supplied fixture (9 PASS, 12 FAIL)

Check

Result

Workflow SHA-256 matches manifest

PASS

Schema SHA-256 matches manifest

PASS

Fixture SHA-256 matches manifest

PASS

Embedded/standalone SQL equivalence, ignoring comments/whitespace

PASS

Tenant policies declared

FAIL

Source-connection RLS enabled

FAIL

Provider contract includes Meta

FAIL

Resolver supports website provider

FAIL

Event unique constraint exists

PASS

Message unique constraint exists

PASS

One-pending-follow-up index exists

PASS

Conversation logical unique constraint exists

FAIL

Claim locking exists

PASS

Qualification update SQL exists

FAIL

HUMAN state update SQL exists

FAIL

Follow-up terminal/recovery update exists

FAIL

Intake persists project binding

FAIL

Supplied demo phone survives Website mapping

FAIL

Supplied demo project survives mapping

FAIL

Supplied STOP fixture recognized

PASS

Query replacements preserve array structure

FAIL — expression returns string; actual driver behavior not tested

Minimal reproductions

A local diagnostic harness can evaluate the attached workflow's snippets without n8n; this is not an n8n emulator:

const vm = require('node:vm');
const run = (nodeName, input, extra = {}) => {
  const node = workflow.nodes.find(node => node.name === nodeName);
  return vm.runInNewContext(
    '(function(){' + node.parameters.jsCode + '})()',
    { $input: { first: () => ({ json: input }) }, ...extra },
    { timeout: 1000 },
  )[0].json;
};

Examples using that harness:

Normalizer input { source: 'website', source_lead_id: 'L1', phone: '+919876543210' } → phone +.

Policy input { tenant_id: 'T', lead_id: 'L', status: 'HUMAN', consent: true, phone: '+919876543210', agent: { action: 'RESPOND' } } → allowed true.

Same input with status NEW and stop: true → allowed true.

Parser input { output: { action: 'RESPOND', score: 'not-a-number', message: 'hi', temperature: 'INVALID', intent: 'INVALID', next_action_hours: -5 } } → accepted agent object with score 0.

The signed-envelope diagnostic used a synthetic secret, Node crypto, and an in-memory provider-shaped payload. It did not use or request a real credential.

8. Supplied acceptance plan disposition

All end-to-end T01–T35 executions are NOT RUN. The table distinguishes a known failed contract from a runtime test blocked by missing execution evidence. It must not be read as a live test report.

Test

Audit disposition

Reason

T01 Meta lead stored

FAIL — static contract

Native Meta adapter absent

T02 Website lead stored

FAIL — local mapping/static contract

Phone corruption; website provider unresolved

T03 duplicate lead

FAIL — guard contract; DB replay NOT RUN

Bypass, unstable fallback IDs, no failed-event recovery

T04 tenant resolution

FAIL — guard contract

Authentication-method mismatch and bypass

T05 wrong-tenant payload

BLOCKED end-to-end

Direct tenant field omitted, but connection selector spoofing remains

T06 outbound WhatsApp

BLOCKED live; known defects

Context/phone/sender binding unresolved

T07 inbound persistence

FAIL — local mapping

Native envelope not extracted

T08 memory

BLOCKED runtime

Fragmented conversations and context/memory-table unknowns

T09 project knowledge

FAIL — intake contract

Project binding dropped

T10 qualification validity

FAIL — parser unit contract

Invalid structured fields accepted

T11 qualification persisted

FAIL — static contract

No qualification writes

T12 follow-up scheduled

BLOCKED runtime

Scheduling SQL exists; action context not verified

T13 reply suppresses stale job

FAIL — static safety contract

No deterministic freshness gate

T14 STOP blocks automation

FAIL — local policy contract

STOP flag ignored; phrase coverage incomplete

T15 human request escalation

BLOCKED runtime

Model-dependent email path; no ownership persistence

T16 HUMAN stops AI

FAIL — local policy/static contract

No pre-agent HUMAN guard; RESPOND allowed

T17 hand-back retains history

FAIL — static contract

Trusted hand-back transition absent

T18 tenant isolation

BLOCKED DB execution; policy contract FAIL

No policies/application-role evidence

T19 invalid source auth

FAIL — local/static contract

Invalid key can carry WhatsApp selector

T20 malformed output no effects

FAIL — parser contract

Some malformed objects accepted; JSON/action rejection only partial

T21 claim concurrency

BLOCKED DB execution

Lock exists; no concurrent transaction test

T22 processing recovery

FAIL — static contract

No recovery/terminal transition

T23 duplicate WhatsApp

FAIL — mapping/identity contract

Provider ID not extracted

T24 duplicate visit

BLOCKED runtime; known guard gaps

Event boundary and visit identity incomplete

T25 signature verification

BLOCKED live

Synthetic HMAC path exercised only; real raw bytes/config unverified

T26 large/malformed payload

NOT RUN boundary suite

Guard present; structured payload validation insufficient

T27 provider failure recovery

FAIL — static recovery contract

Logging node is not event/job/send reconciliation

T28 unknown event

BLOCKED runtime

Logging route exists; early ACK/parameter behavior unverified

T29–T32 future 99acres

NOT RUN — intentionally out of scope

Do not implement now

T33 demo tenant works

BLOCKED end-to-end

Seed/fixture exist; project not seeded/bound

T34 config-only transition

NOT VERIFIED

Tenant channel configuration and real provider testing unresolved

T35 no production fork

PASS — artifact structure only

One supplied workflow/schema; runtime parity NOT VERIFIED

9. Demo → production parity

VERIFIED structurally: one current workflow and one equivalent schema migration are supplied; the fixture explicitly declares synthetic data, no live result, and no credentials. There is no separate production workflow in the available attachments.

NOT VERIFIED operationally: no demo execution or production execution was performed. The migration unconditionally seeds Demo Builder and placeholder source connections; the demo project/lead fixture is not loaded by the workflow. The current global sender/notification configuration is not a proven multi-client transition model.

Keep the same repaired workflow, schema, policy, qualification, and follow-up logic in both environments. Separate demo seed data from structural migration; configure tenant/project/source/channel records and credentials without forking business logic. Run the same acceptance suite with test assets before real client assets. A simulated flat Meta fixture cannot substitute for the native Meta adapter in a parity claim.

Conclusion: the intended parity contract is clear; actual demo → configuration → test → live parity cannot yet be confirmed.

10. Future 99acres adapter boundary — contract only

The supplied SOURCE_ADAPTER_CONTRACT.md correctly describes:

source verification/extraction → canonical lead.created → trusted tenant/idempotency → existing lead/conversation/qualification/policy/action/follow-up core

When a real client requires 99acres, only its documented source authentication, extraction/lookup if required, normalization, stable ID, and trusted connection mapping should be added. The adapter must preserve unknowns as null, must not trust inbound tenant IDs, and must not duplicate qualification, WhatsApp, follow-up, opt-out, memory, or human takeover.

Current limitations: the schema does not yet support that provider; the canonicalizer omits connection_id, generates timestamp fallbacks, and loses fields. The existing core must first be repaired for the locked Meta/Website/WhatsApp scope. No 99acres API availability, endpoint, credential, webhook shape, or implementation is claimed. T29–T32 remain deferred.

11. Test-only unknowns and live gates

The following must not be promoted from uncertainty to an observed live failure or live success:

Installed n8n/node versions, Code-node modes, linked-item behavior, Postgres outputs, agent output envelope, query-parameter conversion, structured-parser mode, and HTTP response context.

Raw signed bytes exposed by the webhook/binary configuration. Security currently falls back to JSON.stringify(body), which is not guaranteed byte-identical to signed input. require('crypto') availability in the actual Code-node sandbox also requires verification.

GET/POST output routing, verification response behavior, rejection status codes, and whether early acknowledgement loses provider retries after downstream failure.

Meta assets/subscriptions/permissions and real lead-detail retrieval; WhatsApp inbound subscriptions and outbound delivery.

Provider messaging-window/template requirements for first contact and delayed follow-up. The current sender emits text only; no template/window selection is present. Verify applicable provider rules with the real setup before enabling outreach.

Actual database schema drift, role privileges, RLS under the app role, tenant-context behavior under pooling, concurrency, rollback, and migrations on an existing database.

Error-workflow binding, SMTP credentials, delivery routing, and error/PII retention. saveDataErrorExecution: 'all' and full error/event payload logging require review against actual captured data; no credential leak was asserted.

Model adherence to verified facts, prompt-injection resistance, qualification quality, fallback handling, and history retention across human hand-back.

Failure injection around acknowledgement, event persistence, provider timeout, duplicate delivery, crash/restart, opt-out races, and job recovery.

No integration connection or environment inventory was requested because this phase did not implement or execute integration code. Placeholder references in an exported n8n file do not establish whether credentials exist in another environment. This audit makes no claim that the user's external services are absent.

12. Bounded repair order after the audit gate

This is a repair sequence for the existing implementation, not an architecture redesign or a record of completed changes:

Correct the graph and provider-bound authentication/tenant resolution; preserve trusted connection identity; reject unauthorized event types.

Implement the actual locked Meta and Website adapter paths and native WhatsApp message mapping; fix phone/null/ID normalization and project binding.

Align standalone and embedded SQL: least-privilege tenant policies, tenant-consistent references, conversation identity, and durable event/job transitions. Obtain approval before applying database migrations.

Repair explicit context transfer and supported SQL parameter binding; validate full AI output; persist qualification; require verified facts or escalation.

Enforce STOP/HUMAN before AI, trusted hand-back, stale-job invalidation, tenant-bound outbound routing, final send authorization, and job/send recovery in the same core.

Execute the supplied relevant T01–T28 and T33–T35 scenarios with actual n8n/Postgres, then provider test assets; repair demonstrated failures and repeat affected tests. Do not implement deferred T29–T32.

13. Exact final state

Inspected: supplied current workflow, matching schema, fixture, test plan, and available instructions/manifests.

Broken: trust-order/auth binding, normalization/adapters, suppression controls, project/qualification persistence, and event/job recovery, with additional context/isolation risks documented above.

Changed: only AUDIT.md; temporary diagnostic copies were removed. Original attachments, application scaffold, workflow, and schema remain unchanged.

Executed: 40 scoped diagnostic assertions; 15 PASS and 25 FAIL. No complete supplied acceptance case was executed end-to-end.

Unverified: live integrations, actual n8n behavior, database role/policies/concurrency, outbound delivery, and demo/production operation. Required reference comparison is blocked by missing files.

Readiness: NOT READY; no production/live verification claim.

Stop: audit-only gate honored. Fix → test → repair has not been represented as completed.