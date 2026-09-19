-- Extracted from current V2(2) workflow DB — Schema Migration node.
-- Not independently executed in a live Postgres environment here.

create extension if not exists pgcrypto;
create table if not exists tenants(id uuid primary key default gen_random_uuid(),name text not null,status text not null default 'ACTIVE',created_at timestamptz not null default now());
create table if not exists projects(id uuid primary key default gen_random_uuid(),tenant_id uuid not null references tenants(id) on delete cascade,name text not null,status text not null default 'ACTIVE',knowledge jsonb not null default '{}'::jsonb,created_at timestamptz not null default now());
create table if not exists leads(id uuid primary key default gen_random_uuid(),tenant_id uuid not null references tenants(id) on delete cascade,source text not null,source_lead_id text not null,project_id uuid references projects(id),name text,phone text,email text,property_type text,budget text,location text,timeline text,message text,consent boolean not null default false,status text not null default 'NEW',temperature text,lead_score integer check(lead_score between 0 and 100),intent text,next_action_at timestamptz,last_contacted_at timestamptz,opted_out_at timestamptz,created_at timestamptz not null default now(),updated_at timestamptz not null default now(),unique(tenant_id,source,source_lead_id));
create index if not exists leads_due_idx on leads(status,next_action_at); create index if not exists leads_phone_idx on leads(tenant_id,phone);
create table if not exists lead_events(id uuid primary key default gen_random_uuid(),tenant_id uuid not null references tenants(id) on delete cascade,lead_id uuid references leads(id) on delete cascade,event_type text not null,external_event_id text,payload jsonb not null default '{}'::jsonb,created_at timestamptz not null default now(),unique(tenant_id,event_type,external_event_id));
create table if not exists conversations(id uuid primary key default gen_random_uuid(),tenant_id uuid not null references tenants(id) on delete cascade,lead_id uuid not null references leads(id) on delete cascade,channel text not null,status text not null default 'OPEN',created_at timestamptz not null default now(),updated_at timestamptz not null default now());
create table if not exists conversation_messages(id uuid primary key default gen_random_uuid(),tenant_id uuid not null references tenants(id) on delete cascade,conversation_id uuid not null references conversations(id) on delete cascade,external_message_id text,direction text not null check(direction in('INBOUND','OUTBOUND')),content text not null,metadata jsonb not null default '{}'::jsonb,created_at timestamptz not null default now(),unique(tenant_id,external_message_id));
create table if not exists followups(id uuid primary key default gen_random_uuid(),tenant_id uuid not null references tenants(id) on delete cascade,lead_id uuid not null references leads(id) on delete cascade,scheduled_at timestamptz not null,status text not null default 'PENDING',reason text,created_at timestamptz not null default now()); create index if not exists followups_due_idx on followups(status,scheduled_at);
create table if not exists site_visits(id uuid primary key default gen_random_uuid(),tenant_id uuid not null references tenants(id) on delete cascade,lead_id uuid not null references leads(id) on delete cascade,scheduled_at timestamptz not null,status text not null default 'SCHEDULED',notes text,created_at timestamptz not null default now(),updated_at timestamptz not null default now());
create table if not exists audit_logs(id uuid primary key default gen_random_uuid(),tenant_id uuid,lead_id uuid,actor_type text not null,action text not null,allowed boolean,reason text,metadata jsonb not null default '{}'::jsonb,created_at timestamptz not null default now());
create table if not exists system_events(id uuid primary key default gen_random_uuid(),tenant_id uuid,severity text not null,event_type text not null,message text not null,execution_id text,payload jsonb not null default '{}'::jsonb,created_at timestamptz not null default now());
insert into tenants(id,name,status) values('00000000-0000-0000-0000-000000000001','Demo Builder','ACTIVE') on conflict(id) do nothing;
-- Defense-in-depth RLS. The n8n application role is intended to use tenant-scoped SQL predicates;
-- RLS is enabled so future direct app access cannot read rows without a policy context.
-- Do not use the database owner/service role for untrusted client access.
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE followups ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_events ENABLE ROW LEVEL SECURITY;

create table if not exists source_connections(id uuid primary key default gen_random_uuid(),tenant_id uuid not null references tenants(id) on delete cascade,provider text not null check(provider in('whatsapp','internal','website')),external_account_id text,api_key_hash text,status text not null default 'ACTIVE',created_at timestamptz not null default now(),unique(provider,external_account_id),unique(provider,api_key_hash));
create unique index if not exists followups_one_pending_idx on followups(tenant_id,lead_id) where status='PENDING';
insert into source_connections(tenant_id,provider,external_account_id,status) values('00000000-0000-0000-0000-000000000001','whatsapp','REPLACE_WITH_DEMO_PHONE_NUMBER_ID','ACTIVE') on conflict do nothing;
insert into source_connections(tenant_id,provider,api_key_hash,status) values('00000000-0000-0000-0000-000000000001','internal','REPLACE_WITH_SHA256_HEX_OF_DEMO_TENANT_INTERNAL_KEY','ACTIVE') on conflict do nothing;
