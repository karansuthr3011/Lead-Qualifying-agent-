# PRODUCT RULES

1. One reusable core system.
2. WhatsApp-first.
3. Indian real-estate developers.
4. Core = response + qualification + follow-up + human escalation.
5. Postgres/Supabase is the system of record.
6. Demo and production use the same implementation.
7. New lead source = adapter -> canonical event -> existing core.
8. Do not duplicate downstream logic for 99acres/MagicBricks/Housing/etc.
9. Initial target ~= 10 clients.
10. No voice, dashboard, frontend, CRM, custom inbox, billing, Kafka, Kubernetes, microservices.
11. No speculative source integrations.
12. Build only for client requirement, demonstrated failure, or security/data-loss prevention.
13. Never claim live testing without evidence.
14. Preserve working code. Do not rewrite for aesthetics.


## Initial adapter lock
- Implement Meta Lead Ads adapter.
- Implement Website adapter.
- WhatsApp is the primary communication channel.
- Do not implement 99acres, MagicBricks, Housing.com, Google Ads, CRM adapters, voice, dashboard, or other speculative integrations in this phase.
