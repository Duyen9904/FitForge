---
name: clone_ui_from_image
description: >
  Clone a UI design from a reference image into Flutter widget code.
  The image is first thoroughly analyzed (layout, colors, typography, spacing,
  components) before any code is generated, ensuring a pixel-accurate result
  that follows this project's design system.
---

# Clone UI from Image

Generate Flutter widget code that faithfully reproduces a reference image.
**The image MUST be analyzed before any code is written.**

---

## Phase 1 — Image Analysis (MANDATORY)

Before writing a single line of code, produce a structured analysis of the reference image.
Write the analysis as a numbered breakdown covering ALL of the following:

### 1.1 Overall Layout
- Identify the **root layout direction** (Column, Row, Stack, etc.)
- List every **visual section** from top to bottom (or left to right).
- Note any **scrolling behavior** (SingleChildScrollView, ListView, etc.)

### 1.2 Component Inventory
For each visual section, identify:
- **Widget type** (Card, Container, Row, Column, Stack, Image, Icon, Text, etc.)
- **Nesting hierarchy** — which widgets are children of which
- **Interactive elements** (buttons, tap targets, toggles)

### 1.3 Spacing & Sizing
- Estimate **padding / margin** values in logical pixels (use the project's `AppDimensions` constants when they match: 4, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64)
- Estimate **widths / heights** of fixed-size elements
- Identify **border-radius** values (map to `AppDimensions.radiusSmall` 4, `radiusMedium` 8, `radiusLarge` 12, `radiusXLarge` 16, `radiusRound` 24, `radiusCircle` 100)

### 1.4 Colors
- List every distinct color visible in the image.
- For each color, decide:
  - Does it map to an **existing `AppColors` constant**? (primary `#7C5CFF`, primaryLight `#9F86FF`, accent `#FF7EB6`, success `#22C55E`, warning `#F59E0B`, error `#EF4444`, info `#3B82F6`, greys 50-900, etc.)
  - Does it map to a **theme semantic color**? (`theme.colorScheme.surface`, `.onSurface`, `.surfaceVariant`, `.onSurfaceVariant`, `.primary`, `.outline`, etc.)
  - If neither, note the **hex value** explicitly.

### 1.5 Typography
- For every text element, note:
  - **Content** (the literal text or a placeholder description)
  - **Style** — map to Material `textTheme` (e.g. `titleLarge`, `titleMedium`, `bodyMedium`, `labelSmall`)
  - **Weight** (w400 / w500 / w600 / bold)
  - **Custom fontSize** if it deviates from the theme default
  - **Color** (resolved the same way as § 1.4)

### 1.6 Decorations & Effects
- Gradients (map to `AppColors.primaryGradient` or `AppColors.accentGradient` if matching, otherwise specify stops)
- Shadows / elevation
- Borders / divider lines
- Opacity / alpha values
- Rounded clipping (ClipRRect, ClipOval)

### 1.7 State Variations
- Note any implied states: empty state, loading skeleton, error state, dark/light mode differences.
- If the image shows only one state, note what the other states should look like.

### 1.8 Data Mapping
- For every piece of dynamic data visible in the image, define a widget **constructor parameter** with its Dart type.
- For static text (labels, headings), these should be hardcoded strings.

---

## Phase 2 — Code Generation

Using the analysis from Phase 1, generate the Flutter widget following these **project conventions**:

### 2.1 File Structure
```
lib/features/<feature>/widgets/<widget_name>.dart
```
- One public `StatelessWidget` (or `StatefulWidget` only if local animation/state is required).
- Private helper widgets as `_PrefixedName` classes in the same file.
- Keep the file focused — one visual component per file.

### 2.2 Imports & Constants
```dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
```
- **Always** use `AppColors` and `AppDimensions` constants instead of magic numbers.
- Use `Theme.of(context)` for semantic colors and text styles.
- Support **dark mode** by reading `theme.brightness` and using theme colors, never hardcoded light-only colors.

### 2.3 Widget Pattern
```dart
class WidgetName extends StatelessWidget {
  // All dynamic data as final fields
  final String title;
  final VoidCallback? onTap;

  const WidgetName({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Build the widget tree from the component inventory
  }
}
```

### 2.4 Styling Rules
| Rule | Details |
|------|---------|
| Spacing | Use `AppDimensions.spacingN` or `AppDimensions.radiusN` constants |
| Colors | Use `AppColors.*` for brand colors, `theme.colorScheme.*` for semantic colors |
| Text | Use `theme.textTheme.*` with `.copyWith()` for overrides |
| Alpha | Use `.withValues(alpha: 0.X)` (NOT `.withOpacity()`) |
| Borders | Use `theme.colorScheme.outlineVariant` for subtle dividers |
| Gradients | Use `AppColors.primaryGradient` or `AppColors.accentGradient` when applicable |
| Padding | Prefer `EdgeInsets.symmetric()` or named constructors over `EdgeInsets.all()` for clarity |
| Border Radius | Use `BorderRadius.circular(AppDimensions.radiusX)` |

### 2.5 Private Sub-Widgets
- Extract repetitive or complex sections into private widget classes (`_SectionHeader`, `_StatCard`, etc.)
- Pass `ThemeData theme` as a constructor parameter to avoid repeated `Theme.of(context)` lookups in sub-widgets.

### 2.6 Responsiveness
- Use `Expanded`, `Flexible`, `MediaQuery` where appropriate.
- Avoid hardcoded widths for container widgets that should stretch; use `double.infinity`.
- Use `maxLines` + `overflow: TextOverflow.ellipsis` for text that might be long.

---

## Phase 3 — Self-Review Checklist

Before delivering the code, verify:

- [ ] Every color in the analysis maps to `AppColors.*` or `theme.colorScheme.*` (no raw hex except brand-new colors)
- [ ] Every spacing value uses an `AppDimensions` constant
- [ ] All text uses `theme.textTheme.*` with `.copyWith()`
- [ ] Widget supports dark mode (no hardcoded light-only colors)
- [ ] Constructor has all dynamic data as `required` parameters
- [ ] Optional callbacks use nullable `VoidCallback?`
- [ ] Private helpers are used for repeated patterns
- [ ] File has a doc comment `///` explaining what the widget renders
- [ ] No unused imports

---

## Quick Reference: Project Design Tokens

### AppColors
| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#7C5CFF` | Primary violet |
| `primaryLight` | `#9F86FF` | Lighter violet |
| `primaryDark` | `#5B3DCC` | Darker violet |
| `accent` | `#FF7EB6` | Pink accent |
| `success` | `#22C55E` | Green |
| `warning` | `#F59E0B` | Amber |
| `error` | `#EF4444` | Red |
| `info` | `#3B82F6` | Blue |
| `grey50`–`grey900` | Cool grey scale | Neutral shades |

### AppDimensions (Spacing)
`2, 4, 6, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64`

### AppDimensions (Radius)
| Token | Value |
|-------|-------|
| `radiusSmall` | 4 |
| `radiusMedium` | 8 |
| `radiusLarge` | 12 |
| `radiusXLarge` | 16 |
| `radiusRound` | 24 |
| `radiusCircle` | 100 |
