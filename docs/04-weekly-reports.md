# Weekly reports

These reports record the project progress as the app moves from the planned design into a tested final submission.

---

## Week 1 (2026-09-22 to 2026-09-26)

**Done this week**
- Built the main Gift Planner scaffold with Flutter and Supabase.
- Added the Recipient, Occasion, and Gift Plan models and Supabase-backed services.
- Added the authentication flow and the eight planned application screens/flows.
- Added reusable widgets, the Material theme, and the PostgreSQL schema with Row Level Security policies.

**In progress**
- Live Supabase configuration and end-to-end testing.
- Analyzer/test verification on the development machine.

**Blocked or stuck on**
- The initial implementation had not yet been verified with a local Flutter SDK and a live Supabase project.

**Decisions made, and why**
- Kept state management to `setState` and `FutureBuilder` to avoid unnecessary architecture for the MVP.
- Used build-time `--dart-define-from-file=.env` configuration so local Supabase values stay outside the committed source.
- Kept AI gift suggestions and other stretch features outside the MVP.

**Next week I will:**
- Configure and test the Supabase project.
- Run `flutter analyze` and `flutter test`.
- Manually test registration, login, CRUD, history, and logout.
- Capture screenshots and prepare the final demo.

---

## Week 2 (2026-09-28)

**Done this week**
- Restored the committed `.env.example` configuration template.
- Made budget/history displays use Philippine pesos (`₱`) to match the project context and mockup.
- Added the mockup board, mockup PDF, and design-system PDF to `docs/assets/`.
- Replaced the starter documentation placeholders with project-specific proposal, mockup, design-system, demo, and security documentation.
- Updated the GitHub Pages workflow so the Supabase URL and publishable key can be passed from repository Actions secrets into the web build.

**In progress**
- Local Flutter verification and live Supabase testing.
- Real screenshots from the working application.
- Final demo recording.

**Blocked or stuck on**
- The current coding environment used for this repository review does not have the Flutter CLI installed, so the final `flutter analyze`/`flutter test` result must be obtained on the development machine.

**Decisions made, and why**
- Did not claim that analyzer, widget tests, RLS, or deployment were successful before they are actually tested.
- Kept the mockup assets clearly separate from the screenshots that still need to be captured from the running application.

**Next steps**
- Run the Flutter checks locally.
- Fix any compiler/analyzer/test issues.
- Test RLS using two separate Supabase accounts.
- Capture final screenshots and record the demo.
- Push the verified commits and confirm GitHub Pages.
