# REFERENCE PATTERNS — SUMMARY OF THE SUPPLIED REFERENCE CORPUS

## Why only two raw references are included

The full supplied corpus was reviewed at pattern level in the existing analysis.
To reduce Astra's context/credit use, only the two most relevant raw workflows are included:
1. AI Lead Gen Machine - Reply Aware
2. AI Real Estate Marketing Kit

Do not require the rest of the corpus for the current build.

## PATTERN 1 — REPLY-AWARE FOLLOW-UP

Reference:
AI Lead Gen Machine - Reply Aware.

Observed:
Before a scheduled follow-up, the workflow checks current reply state.
If a reply exists, the sequence stops.

USE:
Adopt this principle.

For the real-estate system:
scheduled follow-up -> re-check current conversation/lead state -> send only if still eligible.

## PATTERN 2 — SIMPLE REAL-ESTATE WORKFLOW SHAPE

Reference:
AI Real Estate Marketing Kit.

Observed:
One property-related form is parsed and then routed through AI/output branches.

USE:
Adopt the idea of clear trigger -> processing -> action boundaries.

Do not copy its business logic or Sheet-based storage.

## PATTERN 3 — DURABLE STATE

Across the supplied reference analysis:
several systems use a shared store between event/scheduled steps.

USE:
Adopt durable shared state.
Use Postgres/Supabase for this product.

## PATTERN 4 — PARALLEL BRANCH / MERGE

Some supplied references use fan-out/fan-in.

USE:
Only when an actual requirement creates independent branches that need synchronization.
Not required for the core lead-conversion path.

## PATTERN 5 — MULTI-AGENT CHAINS

Some references use multiple sequential AI agents.

USE:
Do not copy this complexity into the current product.
Current product needs one focused sales agent plus deterministic policy.

## PATTERN 6 — COMPLIANCE CHOKEPOINT

The supplied corpus also documents an SMS compliance-gate pattern.

USE:
Adopt the principle of deterministic gating before sensitive outbound actions.
Do not copy its SMS/Twilio implementation into WhatsApp.

## PATTERN 7 — WHAT NOT TO COPY

Do not import:
- Google Sheets as system of record
- unrelated email workflows
- image-generation pipelines
- multi-agent content engines
- unnecessary waits
- speculative infrastructure

## FINAL REFERENCE DECISION

Useful:
- state re-check before follow-up
- durable state
- clear trigger/processing/action boundaries
- deterministic outbound gating

Not useful for current MVP:
- large agent chains
- visual/content branches
- unrelated business logic
- extra infrastructure
