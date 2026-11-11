# Gym Mobile — Design System Specification

This document defines the 14 foundational pillars of the Gym Mobile Design System, implemented in [`lib/core/constants/`](lib/core/constants/) and exported via [`design_tokens.dart`](lib/core/constants/design_tokens.dart) (with W3C Figma token export in [`design_tokens.json`](lib/core/constants/design_tokens.json)).

---

## 1. Color Palette (`AppColors`)
Defined in [`lib/core/constants/app_colors.dart`](lib/core/constants/app_colors.dart).

### 1.1 Primary, Secondary & Tertiary (Brand Palette)
| Role | Token | Hex | Preview / Usage |
| :--- | :--- | :--- | :--- |
| **Primary** | `AppColors.primary` | `#7C5CFF` | Primary CTAs, active tabs, selected states |
| | `AppColors.primaryLight` | `#9F86FF` | Dark mode primary, hover/pressed highlights |
| | `AppColors.primaryDark` | `#5B3DCC` | Active press states, deep shadows |
| | `AppColors.primaryContainerLight` / `Dark` | `#EDE9FE` / `#2E1B6B` | Tinted badge & icon containers |
| **Secondary** | `AppColors.secondary` | `#B794F4` | Secondary accents, workout progress rings |
| | `AppColors.secondaryLight` / `Dark` | `#D6BCFA` / `#805AD5` | Secondary container & dark mode variants |
| **Tertiary / Accent** | `AppColors.tertiary` (`accent`) | `#FF7EB6` | Tertiary accents, streak highlights |
| | `AppColors.tertiaryLight` / `Dark` | `#FFA3C9` / `#E0569A` | Light/Dark tertiary variants |
| **Athletic Accent** | `AppColors.neonLime` | `#A6F523` | High-contrast PR badges, hero card tags |
| **Dark Hero** | `AppColors.darkHero` | `#1B1E1C` | High-contrast hero workout cards |

### 1.2 Neutral Colors
- **Cool Grey Scale (`grey50` – `grey900`)**:
  - `grey50` (`#F8F9FC`), `grey100` (`#F1F2F6`), `grey200` (`#E2E5EC`), `grey300` (`#C9CED8`), `grey400` (`#9FA6B2`), `grey500` (`#6B7280`), `grey600` (`#4B5563`), `grey700` (`#374151`), `grey800` (`#1F2937`), `grey900` (`#0F172A`).
- **Figma Reference Neutral Scale (`neutralLight01`–`09` & `neutralDark01`–`09`)**:
  - Light: `#FFFFFF`, `#F2F2F7`, `#E5E5EA`, `#D1D1D6`, `#C7C7CC`, `#AEAEB2`, `#8E8E93`, `#3A3A3C`, `#000000`.
  - Dark: `#000000`, `#1C1C1E`, `#2C2C2E`, `#3A3A3C`, `#48484A`, `#636366`, `#8E8E93`, `#AEAEB2`, `#FFFFFF`.

### 1.3 Semantic Colors (Success, Warning, Error, Info)
| Semantic Role | Base (Light) | Base (Dark) | Subtle Container (Light / Dark) | On-Color (Light / Dark) | Border |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Success** | `#22C55E` | `#4ADE80` | `#DCFCE7` / `#14532D` | `#15803D` / `#DCFCE7` | `#86EFAC` |
| **Warning** | `#F59E0B` | `#FBBF24` | `#FEF3C7` / `#78350F` | `#B45309` / `#FEF3C7` | `#FCD34D` |
| **Error** | `#EF4444` | `#F87171` | `#FEE2E2` / `#7F1D1D` | `#B91C1C` / `#FEE2E2` | `#FCA5A5` |
| **Info** | `#3B82F6` | `#60A5FA` | `#DBEAFE` / `#1E3A8A` | `#1D4ED8` / `#DBEAFE` | `#93C5FD` |

### 1.4 Background & Surface Colors
| Token | Light Mode | Dark Mode | Usage |
| :--- | :--- | :--- | :--- |
| `backgroundLight` / `Dark` | `#F6F7FB` | `#0F172A` | Primary `Scaffold` background |
| `backgroundSecondary` | `#F1F2F6` | `#090E1A` | Grouped list/section background |
| `surface1` (`surfaceLight` / `Dark`) | `#FFFFFF` | `#1E293B` | Cards (`AppSurfaceCard`), sheets, bars |
| `surface2` | `#F8F9FC` | `#273549` | Nested cards, secondary containers |
| `surface3` | `#F1F2F6` | `#334155` | Input fills, segmented control tracks |
| `scrimLight` / `scrimDark` | `#660F172A` | `#99000000` | Modal & bottom sheet backdrop scrim |

### 1.5 Text & Border Colors
| Role | Light Token & Hex | Dark Token & Hex |
| :--- | :--- | :--- |
| **Text Primary** | `textPrimaryLight` (`#0F172A`) | `textPrimaryDark` (`#F8F9FC`) |
| **Text Secondary** | `textSecondaryLight` (`#4B5563`) | `textSecondaryDark` (`#C9CED8`) |
| **Text Tertiary** | `textTertiaryLight` (`#6B7280`) | `textTertiaryDark` (`#9FA6B2`) |
| **Text Disabled** | `textDisabledLight` (`#9FA6B2`) | `textDisabledDark` (`#4B5563`) |
| **Text Inverse** | `textInverseLight` (`#FFFFFF`) | `textInverseDark` (`#0F172A`) |
| **Border Subtle** | `borderSubtleLight` (`#E2E5EC`) | `borderSubtleDark` (`#1F2937`) |
| **Border Default** | `borderDefaultLight` (`#C9CED8`) | `borderDefaultDark` (`#374151`) |
| **Border Strong** | `borderStrongLight` (`#9FA6B2`) | `borderStrongDark` (`#4B5563`) |
| **Border Focus** | `borderFocusLight` (`#7C5CFF`) | `borderFocusDark` (`#9F86FF`) |

---

## 2. Typography (`AppTextStyles`)
Defined in [`lib/core/constants/app_text_styles.dart`](lib/core/constants/app_text_styles.dart), matching the Figma Typography Specimen (`node-id=2:20`) and Material 3.

- **Font Families (`AppFontFamilies`)**:
  - `primary`: `Outfit` (or system default sans-serif)
  - `monospace`: `monospace` (for rest timers, stopwatch, and tabular workout metrics)
- **Font Weights (`AppFontWeights`)**:
  - `regular` (`w400`), `medium` (`w500`), `semiBold` (`w600`), `bold` (`w700`), `extraBold` (`w800`)

| Group | TextStyle Token | Font Size | Line Height (px / ratio) | Weight | Letter Spacing |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Display** | `displayLarge` (h1) | `57sp` (`64sp` ref) | `64px` (`1.12`) | `w700` | `-0.25px` |
| | `displayMedium` (h2) | `45sp` (`56sp` ref) | `52px` (`1.16`) | `w700` | `0px` |
| | `displaySmall` (h3) | `36sp` (`48sp` ref) | `44px` (`1.22`) | `w600` | `0px` |
| **Headline** | `headlineLarge` (h4) | `32sp` (`40sp` ref) | `40px` (`1.25`) | `w600` | `0px` |
| | `headlineMedium` (h5) | `28sp` | `36px` (`1.29`) | `w600` | `0px` |
| | `headlineSmall` (h6) | `24sp` | `32px` (`1.33`) | `w600` | `0px` |
| **Title** | `titleLarge` | `22sp` (`20sp` ref) | `28px` (`1.27`) | `w600` | `0px` |
| | `titleMedium` | `16sp` | `24px` (`1.50`) | `w600` | `0.15px` |
| | `titleMediumRegular` | `16sp` | `24px` (`1.50`) | `w400` | `0.15px` |
| | `titleSmall` | `14sp` | `20px` (`1.43`) | `w600` | `0.10px` |
| | `titleSmallRegular` | `14sp` | `20px` (`1.43`) | `w400` | `0.10px` |
| **Body** | `bodyLarge` | `16sp` | `24px` (`1.50`) | `w400` | `0.50px` |
| | `bodyMedium` | `14sp` | `20px` (`1.43`) | `w400` | `0.25px` |
| | `bodySmall` | `12sp` | `16px` (`1.33`) | `w400` | `0.40px` |
| **Button** | `buttonLarge` | `16sp` | `24px` (`1.50`) | `w600` | `0.50px` |
| | `buttonMedium` (`button`) | `14sp` | `20px` (`1.43`) | `w600` | `1.25px` |
| | `buttonSmall` | `12sp` | `16px` (`1.33`) | `w600` | `0.50px` |
| **Label** | `labelLarge` | `14sp` | `20px` (`1.43`) | `w500` | `0.10px` |
| | `labelMedium` | `12sp` | `16px` (`1.33`) | `w500` | `0.50px` |
| | `labelSmall` | `11sp` | `16px` (`1.45`) | `w500` | `0.50px` |
| | `labelXSmall` | `10sp` | `14px` (`1.40`) | `w500` | `0.50px` |
| **Metrics** | `timerDisplay` / `metricValue` | `36sp` / `28sp` | `44px` / `36px` | `w700` | Tabular figures |

---

## 3. Spacing System (`AppSpacing`)
Defined in [`lib/core/constants/app_dimensions.dart`](lib/core/constants/app_dimensions.dart).
- **4dp Base Grid + Micro Steps**: `0, 2, 4, 6, 8, 10, 12, 14, 16, 20, 24, 32, 40, 48, 56, 64, 80, 96`.
- **Semantic Aliases**: `xxs (2)`, `xs (4)`, `sm (8)`, `md (12)`, `lg (16)`, `xl (20)`, `xxl (24)`, `xxxl (32)`, `huge (48)`.
- **Layout Tokens**:
  - `inlineGap`: `8dp` (icon-to-label, chip spacing)
  - `itemGap`: `12dp` (vertical list item gap)
  - `cardPadding`: `16dp` (`AppSurfaceCard` default padding)
  - `heroCardPadding`: `20dp` (`AppDarkHeroCard` default padding)
  - `sectionGap`: `24dp` (gap between major dashboard sections)
  - `screenHorizontal`: `16dp`, `screenVertical`: `24dp`

---

## 4. Sizing System (`AppSizing`)
Defined in [`lib/core/constants/app_dimensions.dart`](lib/core/constants/app_dimensions.dart).
- **Touch Targets**: `minTouchTargetIos = 44dp`, `minTouchTargetAndroid = 48dp`
- **Buttons**: `buttonHeightSm = 36dp`, `buttonHeightMd = 44dp`, `buttonHeightLg = 52dp`
- **Inputs**: `inputHeightSm = 40dp`, `inputHeightMd = 48dp`, `inputHeightLg = 52dp`, `searchBarHeight = 44dp`
- **Avatars**: `xs = 24dp`, `sm = 32dp`, `md = 40dp`, `lg = 56dp`, `xl = 80dp`, `profile = 96dp`
- **Chips & Badges**: `badgeDotSize = 7dp`, `chipHeightSm = 24dp`, `chipHeightMd = 32dp`, `chipHeightLg = 38dp`
- **Navigation**: `appBarHeight = 56dp`, `bottomNavHeight = 80dp`, `bottomSheetHandle = 36x4dp`

---

## 5. Grid System & Layout (`AppGrid`)
Defined in [`lib/core/constants/app_layout.dart`](lib/core/constants/app_layout.dart).
| Viewport Class | Columns | Outer Margin | Gutter | Max Content Width |
| :--- | :--- | :--- | :--- | :--- |
| **Mobile (`compact`)** | `4` | `16dp` | `12dp` | `480dp` |
| **Tablet Portrait (`medium`)** | `8` | `24dp` | `16dp` | `768dp` |
| **Tablet Landscape / Desktop (`expanded`)** | `12` | `32dp` | `24dp` | `1200dp` |

Helper methods: `AppGrid.columnsForWidth(w)`, `AppGrid.singleColumnWidth(w)`, and `AppGrid.spanWidth(w, span)`.

---

## 6. Breakpoints & Responsive Rules (`AppBreakpoints`)
Defined in [`lib/core/constants/app_layout.dart`](lib/core/constants/app_layout.dart).
- **`compact` (`< 600dp`)**: Single-column feed, bottom navigation bar (`80dp`), full-width modal bottom sheets.
- **`medium` (`600dp – 839dp`)**: 2-column workout/exercise card grids, optional navigation rail, constrained dialog sheets.
- **`expanded` (`>= 840dp`)**: Multi-pane master-detail view, persistent side navigation, centered content container (`max 1200dp`).

---

## 7. Border Radius (`AppRadius`)
Defined in [`lib/core/constants/app_dimensions.dart`](lib/core/constants/app_dimensions.dart).
| Token | Value | Usage |
| :--- | :--- | :--- |
| `AppRadius.none` | `0dp` | Full-bleed banners, sharp dividers |
| `AppRadius.xs` (`radiusSmall`) | `4dp` | Progress bars, micro tags |
| `AppRadius.sm` (`radiusMedium`) | `8dp` | `AppBadgeChip`, inner thumbnails |
| `AppRadius.md` (`radiusLarge`) | `12dp` | Buttons (`PrimaryButton`), text inputs, snackbars |
| `AppRadius.lg` (`radiusXLarge`) | `16dp` | Standard Material cards, dialogs |
| `AppRadius.xl` (`radius20`) | `20dp` | `AppSurfaceCard`, `AppDarkHeroCard` |
| `AppRadius.xxl` (`radiusRound`) | `24dp` | Bottom sheet top corners, large popups |
| `AppRadius.xxxl` | `32dp` | Specimen containers, onboarding hero cards |
| `AppRadius.full` | `999dp` | Pills (`AppSelectablePill`), segmented controls, circular avatars |

---

## 8. Borders & Dividers (`AppBorders`)
Defined in [`lib/core/constants/app_borders_and_shadows.dart`](lib/core/constants/app_borders_and_shadows.dart).
- **Stroke Widths**: `widthNone (0)`, `widthHairline (0.5)`, `widthThin (1.0)`, `widthMedium (1.5)`, `widthThick (2.0)`.
- **Border Presets**: `subtleSideLight/Dark`, `defaultSideLight/Dark`, `strongSideLight/Dark`, `focusSideLight/Dark`, `errorSideLight/Dark`.
- **Dividers**: `1.0dp` thickness (`AppColors.dividerLight` / `dividerDark`), supporting full-bleed, leading inset (`16dp`), and middle (`16dp` horizontal margin) variants.

---

## 9. Shadows & Elevation (`AppShadows`)
Defined in [`lib/core/constants/app_borders_and_shadows.dart`](lib/core/constants/app_borders_and_shadows.dart).
| Preset | Elevation | Offset / Blur | Color | Usage |
| :--- | :--- | :--- | :--- | :--- |
| `AppShadows.none` | `0dp` | — | Transparent | Flat containers, filled inputs |
| `AppShadows.xs` | `2dp` | `(0, 2)` / `blur 6` | `3%` `primaryDark` | Compact tiles, floating pills |
| `AppShadows.sm` | `4dp` | `(0, 4)` / `blur 10` | `4%` `primaryDark` | Default `AppSurfaceCard` |
| `AppShadows.md` | `8dp` | `(0, 8)` / `blur 20` | `7%` `grey900` | Sticky headers, dropdown menus |
| `AppShadows.lg` | `12dp` | `(0, 12)` / `blur 32` | `10%` `grey900` | Bottom nav bar, active workout bar |
| `AppShadows.xl` | `24dp` | `(0, 20)` / `blur 48` | `16%` `grey900` | Modals, dialogs |
| `AppShadows.brandGlow` | `8dp` | `(0, 6)` / `blur 16` | `28%` `primary` | Primary CTA highlight glow |
| `AppShadows.darkHero` | `8dp` | `(0, 6)` / `blur 16` | `15%` `grey900` | `AppDarkHeroCard` shadow |

---

## 10. Iconography (`AppIconography`)
Defined in [`lib/core/constants/app_visuals_and_motion.dart`](lib/core/constants/app_visuals_and_motion.dart).
- **Scale**: `xs (14dp)`, `sm (16dp)`, `md (20dp)`, `lg (24dp)`, `xl (32dp)`, `xxl (48dp)`.
- **Stroke & Grid**: `1.75px–2.0px` rounded stroke weight on a `24x24dp` grid with `2dp` optical live-area padding.
- **States**: Outlined icon in `grey400`/`grey500` when unselected; filled/tinted icon in `primary` (`#7C5CFF`) when selected.

---

## 11. Illustration Style (`AppIllustrations`)
Defined in [`lib/core/constants/app_visuals_and_motion.dart`](lib/core/constants/app_visuals_and_motion.dart) & [`app_assets.dart`](lib/core/constants/app_assets.dart).
- **Dimensions**: Spot small (`64dp`), Spot medium (`80dp`), Card banner (`140dp` height), Empty/Error state (`180x180dp`), Onboarding hero (`280x280dp`).
- **Visual Direction**: Modern athletic flat-vector illustrations utilizing `primaryGradient` (`#7C5CFF` → `#9F86FF`), `accentGradient`, and `neonLime` highlights, backed by a subtle ambient circle (`8%` opacity in light mode, `14%` in dark mode).

---

## 12. Motion & Animation (`AppMotion`)
Defined in [`lib/core/constants/app_visuals_and_motion.dart`](lib/core/constants/app_visuals_and_motion.dart).
- **Durations**:
  - `instant`: `50ms` (tap feedback)
  - `fast`: `150ms` (chip/pill toggles, icon transitions)
  - `normal`: `250ms` (segmented control slide, card transitions)
  - `slow`: `350ms` (bottom sheets, modal reveals)
  - `pageTransition`: `400ms` (route transitions)
  - `shimmerCycle`: `1500ms` (`ShimmerPlaceholder` loop)
- **Curves**: `standard` (`Curves.easeOutCubic`), `emphasized` (`Curves.easeInOutCubicEmphasized`), `decelerate` (`Curves.decelerate`), `accelerate` (`Curves.easeInCubic`), `bounce` (`Curves.elasticOut`), plus `snappySpring` & `gentleSpring`.

---

## 13. Z-Index Layers (`AppZIndex`)
Defined in [`lib/core/constants/app_visuals_and_motion.dart`](lib/core/constants/app_visuals_and_motion.dart).
| Layer Token | Value | Component Examples |
| :--- | :--- | :--- |
| `AppZIndex.base` | `0` | Scrollable page content, standard cards |
| `AppZIndex.raised` | `10` | Sticky section headers, card status badges |
| `AppZIndex.floating` | `20` | Floating Action Buttons (FAB), active workout mini-bar |
| `AppZIndex.navigation` | `30` | `AppBar`, `BottomNavigationBar` |
| `AppZIndex.drawerAndSheet` | `40` | Modal bottom sheets, filter drawers |
| `AppZIndex.modal` | `50` | Dialogs, `LoadingOverlay` |
| `AppZIndex.toast` | `60` | Snackbars, top toast banners |
| `AppZIndex.tooltip` | `70` | Coach marks, tooltips, onboarding spotlights |

---

## 14. Unified Design Tokens (`design_tokens.dart` & `design_tokens.json`)
- **Flutter Import**:
  ```dart
  import 'package:mobile/core/constants/design_tokens.dart';
  ```
- **Figma / Tokens Studio Import**:
  Import [`lib/core/constants/design_tokens.json`](lib/core/constants/design_tokens.json) directly into Figma Variables or Tokens Studio to synchronize all color modes, typography scales, spacing, sizing, radii, and z-index layers.
