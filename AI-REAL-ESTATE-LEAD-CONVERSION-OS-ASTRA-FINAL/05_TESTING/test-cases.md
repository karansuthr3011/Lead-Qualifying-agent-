# CORE TEST PLAN

These are TESTS, not claims of passing.

Mark:
PASS / FAIL / NOT RUN / BLOCKED.

## TIER 1 — DEMO MUST PASS

T01 Meta lead -> lead stored
T02 Website lead -> lead stored
T03 Duplicate lead event -> no duplicate
T04 Correct tenant resolution
T05 Wrong-tenant payload cannot change resolved tenant
T06 WhatsApp outbound works
T07 WhatsApp inbound persists
T08 Conversation memory works
T09 Project knowledge is retrieved
T10 AI qualification output is valid
T11 Qualification persists
T12 Follow-up is scheduled
T13 Customer reply before follow-up -> stale follow-up suppressed
T14 STOP -> future automation blocked
T15 Human request -> escalation
T16 HUMAN state -> AI stops
T17 Hand-back to AI -> history remains
T18 Tenant A cannot read Tenant B
T19 Invalid source authentication -> reject
T20 Malformed AI output -> no side effect

## TIER 2 — IMPORTANT

T21 Follow-up claim concurrency
T22 Follow-up processing recovery
T23 Duplicate WhatsApp message
T24 Duplicate site-visit event
T25 Meta signature verification
T26 Large/malformed payload
T27 Provider failure logging/recovery
T28 Unknown event type

## TIER 3 — FUTURE SOURCE

T29 99acres adapter -> canonical event
T30 99acres duplicate -> core idempotency works
T31 99acres malformed input -> rejected
T32 99acres uses same downstream core

## DEMO -> PRODUCTION

T33 Demo tenant works
T34 Replace config/credentials only
T35 No production workflow fork
