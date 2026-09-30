# AI usage

This project used AI assistance during implementation, debugging, documentation, and repository cleanup. The record below is intentionally specific about what the AI contributed and what still needs to be checked by the student on the actual development machine and Supabase project.

## 1. How I used AI

### 2026-09-26 — Gift Planner application scaffold

- **Tool:** Claude (Anthropic).
- **What I asked for:** Build the Gift Planner MVP from the project specification, including the planned screens, models, Supabase services, reusable widgets, and navigation.
- **What it contributed:** The main Flutter application structure under `lib/`, including models, services, screens, widgets, configuration, and the database integration.
- **What I kept/changed:** I kept the simple `setState`/`FutureBuilder` architecture and the eight-screen MVP scope. The project still needs local compilation and runtime testing before the implementation can be considered verified.
- **Commit:** `0245ed8` — Add Gift Planner application implementation

### 2026-09-26 — Database schema and Row Level Security

- **Tool:** Claude (Anthropic).
- **What I asked for:** Create PostgreSQL tables for recipients, occasions, and gift plans, with owner-based Row Level Security and checks on related records.
- **What it contributed:** `supabase/schema.sql`, including tables, indexes, foreign keys, RLS policies, and `updated_at` triggers.
- **What I kept/changed:** I kept the owner-scoped policies and the related-recipient ownership checks. I did not claim that the policies were tested until I can run them against the real Supabase project.
- **Commit:** `0245ed8` — Add Gift Planner application implementation

### 2026-09-26 — README and project documentation

- **Tool:** Claude (Anthropic).
- **What I asked for:** Turn the course starter documentation into project-specific documentation covering setup, features, structure, screenshots, and known issues.
- **What it contributed:** The first project-specific README and documentation structure.
- **What I kept/changed:** I updated the documentation again during final cleanup so it matches the actual Gift Planner implementation instead of leaving starter placeholders.
- **Commit:** `a390266` — Complete project documentation and submission assets

### 2026-09-28 — Repository review and configuration cleanup

- **Tool:** ChatGPT.
- **What I asked for:** Review the submitted project ZIP for missing pieces, incomplete documentation, configuration problems, and final-submission risks.
- **What it contributed:** Identified the missing `.env.example`, incomplete documentation, the need for real screenshots, and the mismatch between the mockup's Philippine-peso budget display and the app's dollar display.
- **What I changed:** Restored `.env.example`, changed budget/history displays to `₱`, and updated the related widget tests.
- **Commit:** `4415d96` — Fix project configuration and currency display

### 2026-09-28 — Mockup, design-system, and security documentation

- **Tool:** ChatGPT.
- **What I asked for:** Organize the completed planning materials into the repository's required `docs/` structure and identify what still needed real-world verification.
- **What it contributed:** Project-specific proposal, mockup documentation, design-system documentation, demo-video plan, security documentation, security checklist, and the visual assets placed under `docs/assets/`.
- **What I changed:** I kept the documents honest by marking live RLS testing, Flutter testing, final screenshots, and the demo video as pending until they are actually completed.
- **Commit:** `a390266` — Complete project documentation and submission assets

### 2026-09-28 — GitHub Pages deployment configuration

- **Tool:** ChatGPT.
- **What I asked for:** Check why the existing GitHub Pages workflow would build the app without the Supabase configuration and prepare it to use repository Actions secrets.
- **What it contributed:** Updated `.github/workflows/deploy-web.yml` so `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` are passed to the Flutter web build using `--dart-define`.
- **What I kept/changed:** The workflow still uses the publishable key only; no Supabase secret/service-role key is added to the web build.
- **Commit:** `01c390f` — Configure Supabase for GitHub Pages deployment

### 2026-09-28 — Security review of gift-plan relationships

- **Tool:** ChatGPT.
- **What I asked for:** Review the Supabase ownership policies for cross-user references.
- **What it contributed:** Identified that gift-plan insert/update checks verified recipient ownership but should also verify an optional linked occasion belongs to the same user.
- **What I changed:** Added an RLS condition requiring `occasion_id` to be null or to reference an occasion owned by the signed-in user.
- **Commit:** `3d8160e` — Tighten gift plan ownership checks

## 2. Where the AI got it wrong

### Case 1 — Deprecated navigation approach

- **What it gave me:** An earlier version of the recipient-details flow used `WillPopScope` to report changes when navigating back.
- **What was wrong with it:** `WillPopScope` is deprecated in current Flutter in favor of newer navigation APIs, and the extra plumbing was unnecessary for this project.
- **What I did instead:** Removed that approach and made the recipient list reload when returning from details, which is simpler for this MVP.
- **Commit:** `0245ed8`

### Case 2 — Code was not verified by a Flutter build during generation

- **What it gave me:** A large set of Dart files based on the written project specification.
- **What was wrong with it:** The generation environment did not have the Flutter SDK available, so it could not prove that the project compiled against the exact Flutter version used for the course.
- **What I did instead:** I kept `flutter analyze` and `flutter test` as explicit final verification steps instead of claiming they passed. The current repository-review environment also does not have the Flutter CLI, so the result must come from the development machine.
- **Commit:** `4415d96`

### Case 3 — RLS was written but not proven against a live Supabase project

- **What it gave me:** RLS policies designed from the project's ownership requirements.
- **What was wrong with it:** The AI could not access the actual Supabase project, so it could not test cross-user reads, updates, deletes, or related-record ownership.
- **What I did instead:** Documented the exact two-account test that still needs to be performed and did not mark the security test as complete.
- **Commit:** `a390266`

## 3. Who wrote what

The AI-assisted parts are documented above. For the course requirement that a meaningful portion of the code be written by the student, this section must describe code that I personally wrote or substantially rewrote after reviewing the generated implementation.

### Written by me

- **Status:** I still need to complete this section with a code change I personally write and understand.
- **What I will do:** After the application passes its first local test run, I will personally implement or substantially rewrite one meaningful part of the app (for example, a validation rule, a reusable widget, or a screen interaction), test it, and record the file and commit here.

### The AI-written part I understand best

- **File:** `supabase/schema.sql`
- **What it does:** Creates the three application tables and uses Row Level Security to make each user's records private.
- **Why it is structured this way:** Every application record carries `user_id`, and related occasions/gift plans also verify ownership of the referenced recipient. This provides database-level privacy instead of relying only on Flutter filters.
- **Commit:** `0245ed8`

### 2026-09-28 — Recipient flow and filter usability fixes

- **Tool:** ChatGPT.
- **What I asked for:** Review the real-app behavior after testing showed stale list results, repeated recipient entry, and confusing gift-plan status filters.
- **What it contributed:** A local list-state approach for recipients, returning saved model objects from forms, an **Add new recipient** action inside occasion/gift-plan forms, and local status filtering for gift plans/history.
- **What I changed:** I kept the changes focused on the existing MVP instead of adding new features. Save results are now passed back to the parent screen, new recipients can be created from a form and immediately selected, and status chips filter the already-loaded list instead of making a network request for every tap.
- **Important limitation:** The changes still need to be compiled and exercised with the course Flutter SDK on the development machine because this review environment does not have Flutter installed.
- **Commit:** `2bd3923` — Improve recipient flow and list filtering
