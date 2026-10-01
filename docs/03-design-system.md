# Design system

The Gift Planner design system uses a Material 3 theme with a soft purple/pink palette and supports both light and dark modes. The same values are implemented in `lib/theme/app_colors.dart`, `lib/theme/app_spacing.dart`, and `lib/theme/app_theme.dart`.

## Visual reference

[Design system PDF](assets/gift-planner-design-system.pdf)

## Palette

| Role | Hex | Use |
| --- | --- | --- |
| Primary | `#6D4CC2` | Main buttons, active actions, primary emphasis |
| Secondary | `#9B7AD6` | Supporting accents and controls |
| Tertiary / Accent | `#F3A8C8` | Small highlights and supporting emphasis |
| Background | `#FFF7FA` | Main page background |
| Surface | `#FFFFFF` | Cards and input surfaces |
| Text | `#211B3A` | Main text |
| Muted text | `#655D78` | Secondary text |
| Error | `#C94F6D` | Validation errors and overspending |
| Success | `#54BFA5` | Positive state feedback |

The body text colour `#211B3A` on the background `#FFF7FA` has approximately 14:1 contrast, and white text on the primary `#6D4CC2` has approximately 6.2:1 contrast.

## Theme mode

The app supports **light and dark mode**. The theme toggle is available from the top navigation. Both modes keep the same purple/pink visual identity while changing background, surface, and text colors for readability.

## Type scale

| TextTheme slot | Size | Weight | Use |
| --- | ---: | --- | --- |
| `headlineSmall` | 24sp | Bold | Screen titles and major headings |
| `titleMedium` | 16sp | Bold | Card titles and section titles |
| `bodyMedium` | 14sp | Regular | Main body and form text |
| `bodySmall` | 12sp | Regular | Supporting text and metadata |

## Spacing

| Constant | Value |
| --- | ---: |
| `AppSpacing.space8` | 8px |
| `AppSpacing.space16` | 16px |
| `AppSpacing.space24` | 24px |
| `AppSpacing.space32` | 32px |

## Reusable components

| Component | File | Main parameters | Used by |
| --- | --- | --- | --- |
| `AppTopBar` | `lib/widgets/app_top_bar.dart` | title, back/action controls | list and form screens |
| `PrimaryButton` | `lib/widgets/primary_button.dart` | label, onPressed, loading, icon | auth and forms |
| `AppTextField` | `lib/widgets/app_text_field.dart` | controller, label, hint, validation | forms |
| `StatusChip` | `lib/widgets/status_chip.dart` | gift-plan status | gift plans/history |
| `RecipientCard` | `lib/widgets/recipient_card.dart` | recipient, edit/delete callbacks | recipients |
| `OccasionCard` | `lib/widgets/occasion_card.dart` | occasion | dashboard/occasions |
| `GiftPlanCard` | `lib/widgets/gift_plan_card.dart` | plan, edit/delete callbacks | gift plans |
| `BudgetProgress` | `lib/widgets/budget_progress.dart` | budget, spent | gift plans |
| `AppSearchBar` | `lib/widgets/app_search_bar.dart` | controller, change/filter callbacks | recipients |
| `BottomNavBar` | `lib/widgets/bottom_nav_bar.dart` | current index, tap callback | signed-in shell |
| `SectionHeader` | `lib/widgets/section_header.dart` | title, optional action | dashboard/details |
| State views | `lib/widgets/app_state_views.dart` | loading/error/empty states | data-driven screens |

## Screen-to-component mapping

- **Login/Register:** `AppTextField`, `PrimaryButton`, theme typography.
- **Dashboard:** `SectionHeader`, `OccasionCard`, state views.
- **Recipient List:** `AppSearchBar`, `RecipientCard`, `BottomNavBar`.
- **Recipient Form:** `AppTextField`, `PrimaryButton`, `AppTopBar`.
- **Recipient Details:** `AppTopBar`, `OccasionCard`, `GiftPlanCard`, `SectionHeader`.
- **Occasions:** `OccasionCard`, `AppTopBar`, state views.
- **Gift Plans:** `GiftPlanCard`, `BudgetProgress`, `StatusChip`.
- **History:** `StatusChip`, `AppTopBar`, state views.

## Changes since the last version

- The implementation now uses the design-system values directly in Flutter theme files rather than keeping the palette only in the document.
- The project was kept light-only to reduce scope.
- The budget UI uses Philippine pesos (`₱`) to match the intended project context and mockup.
- Reusable components were kept in `lib/widgets/` so the screens do not each create separate versions of the same controls.
