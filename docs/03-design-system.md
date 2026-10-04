# Gift Planner Design System

## Design direction

The app uses a soft and simple visual style. The main goal was to make the screens easy to read while still looking friendly for a gift-planning app.

The application supports both light and dark mode.

## Colors

### Light theme

- Primary: `#6D4CC2`
- Secondary: `#9B7AD6`
- Accent: `#F3A8C8`
- Background: `#FFF7FA`
- Surface: `#FFFFFF`
- Main text: `#211B3A`
- Muted text: `#655D78`
- Error: `#C94F6D`
- Success: `#54BFA5`

### Dark theme

- Background: `#15121C`
- Surface: `#211C2B`
- Surface variant: `#2B2537`
- Main text: `#F8F5FC`
- Muted text: `#B9B1C9`
- Primary: `#AE91E8`
- Secondary: `#C2A8F0`
- Accent: `#F3A8C8`

## Typography

The app uses a small set of text styles instead of using random sizes throughout the screens.

- Headline: 24sp, bold
- Title: 16sp, bold
- Body: 14sp
- Small body: 12sp

## Spacing

The main spacing values are:

- 8
- 16
- 24
- 32

These are kept as named spacing constants so the UI is more consistent.

## Reusable components

Some reusable widgets are:

- `AppTopBar`
- `PrimaryButton`
- `AppTextField`
- `StatusChip`
- `RecipientCard`
- `OccasionCard`
- `GiftPlanCard`
- `BudgetProgress`
- `AppSearchBar`
- `BottomNavBar`
- `SectionHeader`

## Screen/component use

The same components are reused across different screens to keep the app consistent.

For example, `GiftPlanCard` is used to display gift information, while `BudgetProgress` shows spending compared with the budget.

## Theme switching

The app has a theme toggle button. It changes between light and dark mode while the app is running.
