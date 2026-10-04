# Gift Planner Proposal

## The problem, in one sentence

People often forget birthdays and special occasions or struggle to choose gifts while staying within a budget, so Gift Planner keeps recipients, occasions, gift ideas, and planned spending in one place.

## Who it is for

Gift Planner is for individual users who buy gifts for family members, friends, classmates, or other people they know.

## Core features

1. User registration and login
2. Dashboard showing upcoming occasions and gift plans
3. Add, edit, delete, and search recipients
4. Save birthdays and other special occasions
5. Create gift plans with budgets and spending
6. Track gift status
7. View gift planning history
8. Keep each user's records separated with Supabase RLS

## Main data

The app stores:

- Recipient name, relationship, interests, and notes
- Occasion title, date, recipient, and notes
- Gift name, recipient, occasion, budget, amount spent, status, and notes
- User account information through Supabase Authentication

## Out of scope

The final MVP does not include AI gift recommendations, notifications, PDF export, image uploads, sharing, or direct online purchasing.

These can be added later, but the main goal was to finish a working gift-planning application.

## Technology

- Flutter
- Dart
- Supabase Authentication
- Supabase PostgreSQL
- Supabase Row Level Security
- GitHub Pages for the web demo

## Privacy

The application is designed so a signed-in user can only access their own records. RLS policies are used at the database level to protect recipients, occasions, and gift plans.

## Changes from the original plan

The project stayed focused on the main gift-planning workflow. Some stretch ideas, including AI gift suggestions, were left out so the main application could be completed properly.

The final version also includes dark mode, gift-plan spending updates, status filters, history, and improved handling of saved records and occasion dates.
