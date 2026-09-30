# Proposal

## The problem, in one sentence

People often forget birthdays and special occasions or struggle to choose gifts while staying within a budget, so Gift Planner keeps recipients, occasions, gift ideas, and planned spending in one place.

## Who it is for

Gift Planner is for individual users who regularly buy gifts for family members, friends, classmates, or other people they know.

## Core features

1. User registration and login with Supabase Authentication.
2. Dashboard showing upcoming occasions and active gift plans.
3. Add, edit, delete, and search recipients.
4. Save birthdays and other special occasions.
5. Create gift plans with budgets, spending, notes, and status.
6. View gift-planning history.
7. Keep each user's records separated through `user_id` and Supabase Row Level Security.

## Out of scope, and why

The MVP does not require AI gift recommendations, notifications, PDF exporting, recipient image uploads, sharing, or direct online purchasing. These ideas are possible stretch goals, but the project focuses first on a complete and reliable core gift-planning workflow.

## Data the app remembers, and where it is saved

The app stores data in Supabase PostgreSQL:

- **Recipients:** name, relationship, interests, notes, and owner ID.
- **Occasions:** title, date, recipient, notes, and owner ID.
- **Gift plans:** gift name, recipient, occasion, budget, amount spent, status, notes, and owner ID.
- **Authentication:** email/password account information is handled by Supabase Authentication.

The Flutter app communicates with Supabase through the services in `lib/services/`. Row Level Security protects records so a signed-in user can only access their own data.

## Risks

- **Scope:** Adding too many stretch features could make the MVP incomplete, so the core flow stays the priority.
- **Supabase configuration:** The app needs the correct project URL and publishable key at run time.
- **RLS:** Database policies must be tested with more than one account before final submission.
- **Deployment:** GitHub Pages needs the Supabase publishable configuration supplied as repository secrets for the deployed web build.
- **Testing:** The complete app needs local analyzer, widget-test, and manual end-to-end verification before the final demo.

## Changes since the last version

- **2026-09-26:** The implementation moved from the original project plan into the Flutter + Supabase stack used by the current repository.
- **2026-09-26:** The MVP was kept focused on the eight required screens and core CRUD flow; AI recommendations and other stretch features remain optional.
- **2026-09-28:** The repository documentation and submission materials were organized around the actual Flutter implementation, with the mockup and design-system files added under `docs/assets/`.
