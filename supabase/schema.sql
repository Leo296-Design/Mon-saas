-- A executer une seule fois dans Supabase : Project > SQL Editor > New query > coller > Run

create table if not exists kv_store (
  user_id uuid not null references auth.users(id) on delete cascade,
  key text not null,
  value text not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, key)
);

alter table kv_store enable row level security;

create policy "Users can manage their own kv_store rows"
  on kv_store
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create table if not exists subscriptions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  stripe_customer_id text,
  stripe_subscription_id text,
  status text not null default 'inactive',
  current_period_end timestamptz,
  updated_at timestamptz not null default now()
);

alter table subscriptions enable row level security;

create policy "Users can read their own subscription"
  on subscriptions
  for select
  using (auth.uid() = user_id);

-- Aucune policy insert/update/delete pour subscriptions : ces écritures
-- ne doivent passer que par le webhook Stripe (api/stripe-webhook.js),
-- qui utilise la service_role key et contourne RLS. Un utilisateur ne
-- peut donc jamais s'auto-attribuer un abonnement actif.
