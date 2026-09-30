# Security checklist

**Last checked:** 2026-09-28

| # | Check | Answer | Evidence |
| - | --- | --- | --- |
| 1 | Is `.env` excluded from git? | Yes | `.gitignore` contains `.env`, `.env.*`, and keeps `.env.example`. |
| 2 | Is a placeholder `.env.example` committed? | Yes | `.env.example` contains placeholder values only. |
| 3 | Does a search of git history turn up any real secret? | Pending local verification | Run the history search before the final push. If any privileged key appears, rotate it and clean the history before submission. |
| 4 | Is the Supabase `service_role`/secret key anywhere in the app code or repo? | No | The Flutter app reads only `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`; no service-role key is referenced in `lib/`. |
| 5 | Does the deployed web build expose anything unsafe? | Designed to be safe | The web client contains the Supabase URL and publishable key. Data protection comes from RLS; privileged keys must not be included. |
| 6 | Are Row Level Security policies written and enforced? | Yes, written | `supabase/schema.sql` enables RLS on `recipients`, `occasions`, and `gift_plans` and defines owner-scoped CRUD policies. |
| 7 | Have the RLS policies been tested against the live project? | Pending manual test | Test with two separate Supabase accounts and verify cross-user reads/writes fail. |
| 8 | Is there real personal data in sample data, screenshots, or the demo video? | Pending final check | Use invented names, emails, dates, and gift information in the final demo materials. |
| 9 | Are there course or university credentials in the repo? | No known credentials | The app uses Supabase project configuration only. Final repository search should still be performed before submission. |
| 10 | Was a leaked key found and revoked? | N/A unless a real key was exposed | If any privileged credential was ever committed or shared, rotate/revoke it and document the action honestly. |

## Final commands to run locally

```bash
git status
git log -p -G 'sb_secret_|service_role|api_key|password|token' --all
```

Do not paste any real secret into the final report or chat. Record only whether the check passed and what action was taken if it did not.
