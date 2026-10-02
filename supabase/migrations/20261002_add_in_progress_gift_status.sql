-- Allow gift plans to move through Planned -> In Progress -> Purchased -> Completed.
-- Run this in Supabase SQL Editor if the existing database was created before
-- the In Progress status was added.

alter table public.gift_plans
drop constraint if exists gift_plans_status_check;

alter table public.gift_plans
add constraint gift_plans_status_check
check (status in ('planned', 'in_progress', 'purchased', 'completed', 'cancelled'));
