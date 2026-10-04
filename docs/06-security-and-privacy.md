# Security and Privacy

## What the app stores

| Data | Where it is stored | Who can access it |
| --- | --- | --- |
| Account information | Supabase Authentication | The account owner |
| Recipients | Supabase PostgreSQL | The signed-in owner |
| Occasions | Supabase PostgreSQL | The signed-in owner |
| Gift plans | Supabase PostgreSQL | The signed-in owner |

## Supabase configuration

The application uses:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

The local `.env` file is not committed. GitHub Pages receives the values through repository Actions secrets.

A Supabase service-role/secret key is not placed in the Flutter web application.

## Row Level Security

RLS is enabled on the application tables.

The policies check that the signed-in user owns the records they are trying to access.

The policies also check related recipient and occasion ownership where needed.

## Testing

I tested the RLS/security setup and confirmed that the application is intended to keep each user's records separate.

The final app was also checked for the main authentication and data-management flow.

## Privacy

Final screenshots and the demo should use invented sample information. Real passwords, private account information, and Supabase credentials should not be shown.

## Final checklist

- [x] `.env` is kept out of the repository
- [x] `.env.example` contains placeholders only
- [x] No service-role key is used in the client app
- [x] RLS policies are present
- [x] RLS/security testing completed
- [ ] Final screenshots captured
- [ ] Final demo video recorded
