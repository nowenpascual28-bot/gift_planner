# Gift Planner

Gift Planner is a Flutter app that helps users organize recipients, special occasions, gift ideas, and budgets in one place.

## 1. Project overview

People can forget birthdays and other special occasions, or have a gift idea but lose track of the budget. Gift Planner puts these details together so the user can plan gifts more easily.

The app is made for individual users buying gifts for family, friends, classmates, or other people they know.

### Main features

- Register and log in
- Dashboard with upcoming occasions and gift plans
- Add, edit, delete, and search recipients
- Save birthdays and other special occasions
- Create gift plans with budgets and spending
- Track gift status: Planned, In Progress, Purchased, Completed, or Cancelled
- Add spending to an existing gift plan
- View gift planning history
- Light and dark mode
- User data protected with Supabase Row Level Security (RLS)

AI gift suggestions are not part of the MVP. They were kept as a possible future feature.

## 2. Setup and installation

### Requirements

- Flutter
- Dart
- A Supabase project
- Chrome or another supported Flutter device

### Install dependencies

```bash
flutter pub get
```

### Supabase setup

Create the required tables and RLS policies using:

```text
supabase/schema.sql
```

For local development, create a `.env` file based on `.env.example` and add your own Supabase URL and publishable key.

Do not commit the real `.env` file.

### Run the app

```bash
flutter run -d chrome --dart-define-from-file=.env
```

The deployed web version is available at:

https://nowenpascual28-bot.github.io/gift_planner/

## 3. How to use the app

1. Register or log in.
2. Open the Dashboard to see an overview.
3. Add people in the Recipient List.
4. Add birthdays or other occasions.
5. Create gift plans and set a budget.
6. Update the gift status as the plan moves forward.
7. Use Add Spent when more money is spent on a gift.
8. Check History to review previous plans.
9. Use the theme button to switch between light and dark mode.

## 4. Project structure

```text
lib/
  config/       Supabase configuration
  models/       Recipient, Occasion, GiftPlan
  services/     Authentication and Supabase services
  theme/        Colors, spacing, and themes
  widgets/      Reusable UI components
  screens/      Application screens
  main.dart     Application entry point

supabase/
  schema.sql    Database tables and RLS policies

docs/
  01-proposal.md
  02-mockup.md
  03-design-system.md
  04-weekly-reports.md
  05-demo-video.md
  06-security-and-privacy.md
```

## 5. Final screens

The project has these main screens:

1. Login / Registration
2. Dashboard
3. Recipient List
4. Add/Edit Recipient
5. Recipient Details
6. Occasion Screen
7. Gift Plan Screen
8. Gift Planning History

## 6. Screenshots

Final screenshots will be added after the final screenshot capture. They should show the working application and use sample data only.

Recommended files:

- `docs/assets/login-register.png`
- `docs/assets/dashboard.png`
- `docs/assets/recipient-list.png`
- `docs/assets/recipient-form.png`
- `docs/assets/recipient-details.png`
- `docs/assets/occasions.png`
- `docs/assets/gift-plans.png`
- `docs/assets/history.png`

## 7. Testing and final status

I checked the app on my development setup and completed the main testing needed for the final project. The live GitHub Pages demo is also working.

I also tested the Supabase RLS/security rules.

The remaining submission item is the final demo video. The final screenshots are also kept as a separate final-submission step.

## 8. Known issues and future improvements

The current MVP is focused on the main gift-planning flow. Possible future features include:

- AI gift suggestions
- Notifications and reminders
- Recipient profile images
- PDF export
- Sharing gift plans
- Online gift links

## Credits

This project was developed for the final project requirements using Flutter and Supabase.

AI tools were used as development assistants for some coding, debugging, explanations, and documentation. See `AI-USAGE.md` for more details.
