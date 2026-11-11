import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../buttons/app_buttons.dart';

/// A reusable, highly customizable Empty Screen component.
///
/// Designed to display an illustration, title, description, and action button.
/// All elements ([title], [description], [button], [illustration]) are completely
/// nullable, allowing it to adapt to any empty-state scenario.
///
/// Can be used as a standalone screen (set [wrapInScaffold] to `true` or use [EmptyScreen.scaffold])
/// or embedded directly as a child widget in any page or tab.
class EmptyScreen extends StatelessWidget {
  /// The main headline text. Nullable.
  final String? title;

  /// A small supporting description text. Nullable.
  final String? description;

  /// Custom button widget. If provided, takes precedence over [buttonText] and [onButtonPressed].
  final Widget? button;

  /// Text label for the default primary action button. Nullable.
  final String? buttonText;

  /// Callback executed when the default action button is tapped. Nullable.
  final VoidCallback? onButtonPressed;

  /// Optional icon to show inside the default action button.
  final IconData? buttonIcon;

  /// Optional custom width for the action button.
  final double? buttonWidth;

  /// Custom illustration widget. If provided, takes precedence over [illustrationPath].
  final Widget? illustration;

  /// Asset path to the illustration image.
  /// Defaults to [AppAssets.emptyIllustration]. Pass `null` to omit the illustration.
  final String? illustrationPath;

  /// Desired height of the illustration image. Defaults to 220.
  final double? illustrationHeight;

  /// Desired width of the illustration image. Defaults to double.infinity with containment.
  final double? illustrationWidth;

  /// How the illustration image should be fitted. Defaults to [BoxFit.contain].
  final BoxFit illustrationFit;

  /// Custom text style for [title]. If null, uses the theme's [TextTheme.titleLarge].
  final TextStyle? titleStyle;

  /// Custom text style for [description]. If null, uses the theme's [TextTheme.bodyMedium].
  final TextStyle? descriptionStyle;

  /// Padding around the content. Defaults to 32px horizontally and 24px vertically.
  final EdgeInsetsGeometry padding;

  /// Alignment of content inside the scroll view. Defaults to [MainAxisAlignment.center].
  final MainAxisAlignment mainAxisAlignment;

  /// Cross alignment of content. Defaults to [CrossAxisAlignment.center].
  final CrossAxisAlignment crossAxisAlignment;

  /// Text alignment for both title and description. Defaults to [TextAlign.center].
  final TextAlign textAlign;

  /// If `true`, wraps the content inside a [Scaffold]. Useful when presenting as a full screen route.
  final bool wrapInScaffold;

  /// Optional [AppBar] when [wrapInScaffold] is `true`.
  final PreferredSizeWidget? appBar;

  const EmptyScreen({
    super.key,
    this.title,
    this.description,
    this.button,
    this.buttonText,
    this.onButtonPressed,
    this.buttonIcon,
    this.buttonWidth,
    this.illustration,
    this.illustrationPath = AppAssets.emptyIllustration,
    this.illustrationHeight = 220,
    this.illustrationWidth,
    this.illustrationFit = BoxFit.contain,
    this.titleStyle,
    this.descriptionStyle,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacing32,
      vertical: AppDimensions.spacing24,
    ),
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textAlign = TextAlign.center,
    this.wrapInScaffold = false,
    this.appBar,
  });

  /// Factory constructor to use [EmptyScreen] as a full screen with its own [Scaffold].
  const EmptyScreen.scaffold({
    super.key,
    this.title,
    this.description,
    this.button,
    this.buttonText,
    this.onButtonPressed,
    this.buttonIcon,
    this.buttonWidth,
    this.illustration,
    this.illustrationPath = AppAssets.emptyIllustration,
    this.illustrationHeight = 220,
    this.illustrationWidth,
    this.illustrationFit = BoxFit.contain,
    this.titleStyle,
    this.descriptionStyle,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacing32,
      vertical: AppDimensions.spacing24,
    ),
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textAlign = TextAlign.center,
    this.appBar,
  }) : wrapInScaffold = true;

  @override
  Widget build(BuildContext context) {
    final content = _buildBody(context);

    if (wrapInScaffold) {
      return Scaffold(
        appBar: appBar,
        body: SafeArea(child: content),
      );
    }

    return content;
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasIllustration = illustration != null || illustrationPath != null;
    final hasTitle = title != null && title!.trim().isNotEmpty;
    final hasDescription = description != null && description!.trim().isNotEmpty;
    final hasButton = button != null || (buttonText != null && onButtonPressed != null);

    return Center(
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Illustration (Nullable)
            if (hasIllustration) ...[
              _buildIllustration(context),
            ],

            // Spacing after illustration
            if (hasIllustration && (hasTitle || hasDescription || hasButton))
              const SizedBox(height: AppDimensions.spacing24),

            // 2. Title (Nullable)
            if (hasTitle) ...[
              Text(
                title!,
                textAlign: textAlign,
                style: titleStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.white : AppColors.grey900,
                    ),
              ),
            ],

            // Spacing after title
            if (hasTitle && (hasDescription || hasButton))
              const SizedBox(height: AppDimensions.spacing8),

            // 3. Small Description (Nullable)
            if (hasDescription) ...[
              Text(
                description!,
                textAlign: textAlign,
                style: descriptionStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.grey400 : AppColors.grey500,
                      height: 1.4,
                    ),
              ),
            ],

            // Spacing before button
            if ((hasIllustration || hasTitle || hasDescription) && hasButton)
              const SizedBox(height: AppDimensions.spacing24),

            // 4. Action Button (Nullable)
            if (hasButton) ...[
              _buildButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    if (illustration != null) {
      return illustration!;
    }

    if (illustrationPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Image.asset(
          illustrationPath!,
          height: illustrationHeight,
          width: illustrationWidth,
          fit: illustrationFit,
          errorBuilder: (context, error, stackTrace) {
            // Graceful fallback if asset cannot be loaded
            return Container(
              height: illustrationHeight ?? 180,
              width: illustrationWidth ?? 180,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: const Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: AppColors.grey400,
              ),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildButton() {
    if (button != null) {
      return button!;
    }

    if (buttonText != null && onButtonPressed != null) {
      return PrimaryButton(
        text: buttonText!,
        onPressed: onButtonPressed,
        icon: buttonIcon,
        width: buttonWidth,
      );
    }

    return const SizedBox.shrink();
  }
}
