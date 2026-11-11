import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_dimensions.dart';
import 'core/constants/app_theme.dart';
import 'ui/core/buttons/app_buttons.dart';
import 'ui/core/loading/loading_widgets.dart';
import 'ui/core/states/state_widgets.dart';

/// Standalone entry point for previewing the app and individual widgets
/// across multiple device frames, screen sizes, orientations, and locales.
///
/// Run with:
/// ```bash
/// flutter run -t lib/main_preview.dart -d chrome
/// # or
/// flutter run -t lib/main_preview.dart -d windows
/// ```
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    DevicePreview(
      enabled: true,
      defaultDevice: Devices.ios.iPhone13,
      builder: (context) => const ProviderScope(
        child: PreviewHubApp(),
      ),
    ),
  );
}

/// Preview launcher app that lets you toggle between the full application
/// and the isolated Widget Showcase gallery.
class PreviewHubApp extends StatefulWidget {
  const PreviewHubApp({super.key});

  @override
  State<PreviewHubApp> createState() => _PreviewHubAppState();
}

class _PreviewHubAppState extends State<PreviewHubApp> {
  bool _showWidgetCatalog = true;

  @override
  Widget build(BuildContext context) {
    if (!_showWidgetCatalog) {
      return Stack(
        children: [
          const GymPlanApp(),
          Positioned(
            right: 16,
            bottom: 32,
            child: FloatingActionButton.extended(
              heroTag: 'back_to_catalog_btn',
              onPressed: () => setState(() => _showWidgetCatalog = true),
              icon: const Icon(Icons.widgets_outlined),
              label: const Text('Widget Catalog'),
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      );
    }

    return MaterialApp(
      title: 'GymPlan Widget Preview',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: WidgetShowcaseScreen(
        onLaunchFullApp: () => setState(() => _showWidgetCatalog = false),
      ),
    );
  }
}

/// Interactive gallery showcasing individual widgets and design components
class WidgetShowcaseScreen extends StatefulWidget {
  final VoidCallback onLaunchFullApp;

  const WidgetShowcaseScreen({
    super.key,
    required this.onLaunchFullApp,
  });

  @override
  State<WidgetShowcaseScreen> createState() => _WidgetShowcaseScreenState();
}

class _WidgetShowcaseScreenState extends State<WidgetShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _buttonsLoading = false;
  bool _overlayLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Preview Catalog'),
        actions: [
          TextButton.icon(
            onPressed: widget.onLaunchFullApp,
            icon: const Icon(Icons.phone_android, color: Colors.white),
            label: const Text(
              'Open App',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.smart_button), text: 'Buttons'),
            Tab(icon: Icon(Icons.hourglass_top), text: 'Loading'),
            Tab(icon: Icon(Icons.info_outline), text: 'States'),
            Tab(icon: Icon(Icons.palette_outlined), text: 'Theme'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _overlayLoading,
        message: 'Testing Loading Overlay...',
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildButtonsSection(),
            _buildLoadingSection(),
            _buildStatesSection(),
            _buildThemeSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsSection() {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Button Variants',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Row(
              children: [
                const Text('Simulate Loading:'),
                Switch(
                  value: _buttonsLoading,
                  onChanged: (val) => setState(() => _buttonsLoading = val),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing16),
        const Text('PrimaryButton:'),
        const SizedBox(height: AppDimensions.spacing8),
        PrimaryButton(
          text: 'Start Workout',
          icon: Icons.fitness_center,
          isLoading: _buttonsLoading,
          onPressed: () {},
        ),
        const SizedBox(height: AppDimensions.spacing16),
        const Text('SecondaryButton (Outlined):'),
        const SizedBox(height: AppDimensions.spacing8),
        SecondaryButton(
          text: 'View Workout Plan',
          icon: Icons.calendar_month,
          isLoading: _buttonsLoading,
          onPressed: () {},
        ),
        const SizedBox(height: AppDimensions.spacing16),
        const Text('TertiaryButton (Text):'),
        const SizedBox(height: AppDimensions.spacing8),
        Center(
          child: TertiaryButton(
            text: 'Skip this step',
            icon: Icons.arrow_forward,
            onPressed: () {},
          ),
        ),
        const SizedBox(height: AppDimensions.spacing16),
        const Text('Disabled State:'),
        const SizedBox(height: AppDimensions.spacing8),
        const PrimaryButton(
          text: 'Disabled Button',
          onPressed: null,
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      children: [
        Text(
          'Loading Indicators & Shimmers',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spacing16),
        ElevatedButton.icon(
          onPressed: () async {
            setState(() => _overlayLoading = true);
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) setState(() => _overlayLoading = false);
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Trigger Full Overlay (2s)'),
        ),
        const SizedBox(height: AppDimensions.spacing24),
        const Text('Shimmer Placeholders (Skeleton Loading):'),
        const SizedBox(height: AppDimensions.spacing12),
        const ShimmerPlaceholder(height: 120, borderRadius: 12),
        const SizedBox(height: AppDimensions.spacing12),
        Row(
          children: const [
            ShimmerPlaceholder(width: 60, height: 60, borderRadius: 30),
            SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerPlaceholder(height: 16, borderRadius: 4),
                  SizedBox(height: 8),
                  ShimmerPlaceholder(width: 140, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatesSection() {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      children: [
        Text(
          'App State Views',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spacing16),
        Card(
          child: EmptyScreen(
            title: 'No Workouts Scheduled',
            description: 'You have not added any workouts to your schedule yet.',
            buttonText: 'Browse Exercises',
            onButtonPressed: () {},
          ),
        ),
        const SizedBox(height: AppDimensions.spacing16),
        Card(
          child: ErrorState(
            message: 'Unable to reach the GymPlan servers. Please check your connection.',
            onRetry: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      children: [
        Text(
          'Active Theme: ${isDark ? "Dark Mode" : "Light Mode"}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spacing8),
        Text(
          'Tip: Use the Device Preview toolbar at the bottom to toggle Dark / Light mode, rotate screens, switch devices, or adjust text scale.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.grey500,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildColorChip('Primary', AppColors.primary),
            _buildColorChip('Secondary', AppColors.secondary),
            _buildColorChip('Success', AppColors.success),
            _buildColorChip('Warning', AppColors.warning),
            _buildColorChip('Error', AppColors.error),
            _buildColorChip('Grey 100', AppColors.grey100),
            _buildColorChip('Grey 500', AppColors.grey500),
            _buildColorChip('Grey 900', AppColors.grey900),
          ],
        ),
      ],
    );
  }

  Widget _buildColorChip(String name, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
