# Security and privacy

**Last checked:** 2026-09-28

The repository is public, so no privileged Supabase credentials should ever be committed. The application uses a Supabase publishable/anon key on the client and relies on Row Level Security (RLS) to protect user data.

## What this app stores

| Data | Where it lives | Who can see it |
| --- | --- | --- |
| Account email/password authentication | Supabase Authentication | The account owner through Supabase Auth |
| Recipients | Supabase PostgreSQL `recipients` | The signed-in owner of the rows |
| Occasions | Supabase PostgreSQL `occasions` | The signed-in owner of the rows |
| Gift plans | Supabase PostgreSQL `gift_plans` | The signed-in owner of the rows |

The application is designed as a single-user-per-account system. Users do not need access to another user's recipient, occasion, or gift-plan records.

## Secrets

- **Runtime configuration names:** `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`
- **Local location:** `.env`, which is ignored by Git.
- **Committed template:** `.env.example`, containing placeholders only.
- **GitHub Pages:** the deployment workflow reads the values from repository Actions secrets and passes them into the Flutter web build.
- **Public client build:** the Supabase URL and publishable/anon key can be read by a visitor. This is acceptable only because database access is protected by RLS; a Supabase secret/service-role key must never be shipped to the browser.

## What protects the data on the service side

`supabase/schema.sql` enables RLS on all three application tables.

- `recipients` select/update/delete policies require `auth.uid() = user_id`.
- Recipient inserts require the new `user_id` to equal the signed-in user's ID.
- `occasions` policies require the row owner to match `auth.uid()`.
- Occasion inserts/updates also verify that the referenced recipient belongs to the same user.
- `gift_plans` policies require the row owner to match `auth.uid()`.
- Gift-plan inserts/updates also verify that the referenced recipient belongs to the same user.
- Foreign keys use `on delete cascade` where child data should follow a deleted recipient.

## Verification still required before final submission

The SQL policies are written, but they must be tested against the actual Supabase project before claiming the security check is complete. The recommended manual test is:

1. Create test account A.
2. Add a recipient, occasion, and gift plan under A.
3. Create test account B.
4. Confirm B cannot see A's records.
5. Confirm B cannot update or delete A's records.
6. Confirm A can still see and modify A's own records.
7. Delete A's recipient and confirm the expected child records are removed by the configured foreign-key behavior.

## Checklist

- [x] `.env` is ignored by Git and `.env.example` is committed as a placeholder.
- [ ] Git history has been checked locally for real secrets before final push.
- [x] No Supabase `service_role` key is referenced by the Flutter app.
- [x] RLS policies are present for all three application tables.
- [ ] RLS has been manually tested with two separate test accounts.
- [ ] Final screenshots and demo video have been checked to contain only invented sample data.
- [ ] Final repository has been checked for course/university credentials.

If any credential is ever accidentally committed, remove it from the repository and rotate/revoke it in the service where it was issued. Do not rely only on deleting the file from the latest commit.

## Authentication testing note

During final testing, the Supabase default email provider may limit the number of authentication emails that can be sent. This is a Supabase platform limit, not an application bug. For a classroom demo, use an existing test account when possible. If email confirmation is not required for the demo, the Supabase Auth setting **Confirm email** can be disabled so new test accounts do not depend on confirmation emails. For broader real-user testing, configure a custom SMTP provider.
