-- Gift Planner database schema for Supabase (PostgreSQL).
--
-- How to use:
--   1. Open your Supabase project.
--   2. Go to the SQL Editor.
--   3. Paste this whole file and run it.
--
-- This creates the three tables the app needs and turns on Row Level
-- Security (RLS) so that every user can only ever see, insert, update or
-- delete their OWN rows. The app also filters by user_id on every query as
-- a second layer of defense, but RLS is what actually enforces privacy at
-- the database level, so it is required even though the app filters too.

-- Needed for gen_random_uuid().
create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- recipients
-- ---------------------------------------------------------------------------
create table if not exists public.recipients (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  relationship text not null default '',
  interests text not null default '',
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists recipients_user_id_idx on public.recipients (user_id);

alter table public.recipients enable row level security;

create policy "Recipients are selectable by their owner"
  on public.recipients for select
  using (auth.uid() = user_id);

create policy "Recipients are insertable by their owner"
  on public.recipients for insert
  with check (auth.uid() = user_id);

create policy "Recipients are updatable by their owner"
  on public.recipients for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Recipients are deletable by their owner"
  on public.recipients for delete
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- occasions
-- ---------------------------------------------------------------------------
create table if not exists public.occasions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  recipient_id uuid not null references public.recipients (id) on delete cascade,
  title text not null,
  date date not null,
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists occasions_user_id_idx on public.occasions (user_id);
create index if not exists occasions_recipient_id_idx on public.occasions (recipient_id);

alter table public.occasions enable row level security;

-- Ownership is checked on occasions.user_id directly (not by looking through
-- to the recipient), and every insert/update also requires the referenced
-- recipient to belong to the same user, so a related record can never be
-- used to bypass ownership.
create policy "Occasions are selectable by their owner"
  on public.occasions for select
  using (auth.uid() = user_id);

create policy "Occasions are insertable by their owner"
  on public.occasions for insert
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.recipients r
      where r.id = recipient_id and r.user_id = auth.uid()
    )
  );

create policy "Occasions are updatable by their owner"
  on public.occasions for update
  using (auth.uid() = user_id)
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.recipients r
      where r.id = recipient_id and r.user_id = auth.uid()
    )
  );

create policy "Occasions are deletable by their owner"
  on public.occasions for delete
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- gift_plans
-- ---------------------------------------------------------------------------
create table if not exists public.gift_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  recipient_id uuid not null references public.recipients (id) on delete cascade,
  occasion_id uuid references public.occasions (id) on delete set null,
  gift_name text not null,
  budget numeric(12, 2) not null default 0 check (budget >= 0),
  spent numeric(12, 2) not null default 0 check (spent >= 0),
  status text not null default 'planned'
    check (status in ('planned', 'purchased', 'completed', 'cancelled')),
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists gift_plans_user_id_idx on public.gift_plans (user_id);
create index if not exists gift_plans_recipient_id_idx on public.gift_plans (recipient_id);
create index if not exists gift_plans_occasion_id_idx on public.gift_plans (occasion_id);

alter table public.gift_plans enable row level security;

create policy "Gift plans are selectable by their owner"
  on public.gift_plans for select
  using (auth.uid() = user_id);

create policy "Gift plans are insertable by their owner"
  on public.gift_plans for insert
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.recipients r
      where r.id = recipient_id and r.user_id = auth.uid()
    )
    and (
      occasion_id is null
      or exists (
        select 1 from public.occasions o
        where o.id = occasion_id and o.user_id = auth.uid()
      )
    )
  );

create policy "Gift plans are updatable by their owner"
  on public.gift_plans for update
  using (auth.uid() = user_id)
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.recipients r
      where r.id = recipient_id and r.user_id = auth.uid()
    )
    and (
      occasion_id is null
      or exists (
        select 1 from public.occasions o
        where o.id = occasion_id and o.user_id = auth.uid()
      )
    )
  );

create policy "Gift plans are deletable by their owner"
  on public.gift_plans for delete
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- keep updated_at current on every update
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists set_updated_at on public.recipients;
create trigger set_updated_at before update on public.recipients
  for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.occasions;
create trigger set_updated_at before update on public.occasions
  for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.gift_plans;
create trigger set_updated_at before update on public.gift_plans
  for each row execute function public.set_updated_at();
