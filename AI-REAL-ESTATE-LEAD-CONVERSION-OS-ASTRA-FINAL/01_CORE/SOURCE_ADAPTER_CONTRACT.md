# SOURCE ADAPTER CONTRACT

## CORE IDEA

New lead sources plug into the same core through a canonical event.

SOURCE
-> ADAPTER
-> CANONICAL EVENT
-> SHARED CORE

## ADAPTER DOES

- source authentication/verification
- source-specific field extraction
- source API lookup when required
- normalization
- stable external ID preservation
- trusted connection/tenant mapping
- emission of canonical lead event

## ADAPTER DOES NOT

- qualify the lead
- create a second database model
- implement follow-up
- implement opt-out
- implement human takeover
- implement WhatsApp logic
- duplicate the core workflow

## FUTURE 99ACRES EXAMPLE

99acres
-> 99acres intake/auth
-> extract lead
-> map fields
-> canonical `lead.created`
-> existing tenant/idempotency/lead/AI/WhatsApp/follow-up path

This is an architectural contract, not a claim about the current availability or exact API of 99acres.

## TEST EVERY NEW ADAPTER

- valid lead
- duplicate lead
- malformed payload
- unknown source connection
- stable external ID
- canonical mapping
- same downstream core path


## Initial scope
The only lead-source adapters to implement now are Meta Lead Ads and Website. WhatsApp is the communication/inbound conversation channel. Future portals are adapters only and must use the same canonical lead-event boundary.
