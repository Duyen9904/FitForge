import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/state/app_flow_state.dart';
import '../repositories/measurement_repository.dart';
import '../widgets/measurement_option_card.dart';
import 'manual_measurement_form_screen.dart';

/// Entry screen: record measurement via manual entry or InBody scan.
class RecordMeasurementScreen extends ConsumerStatefulWidget {
  const RecordMeasurementScreen({super.key});

  @override
  ConsumerState<RecordMeasurementScreen> createState() =>
      _RecordMeasurementScreenState();
}

class _RecordMeasurementScreenState extends ConsumerState<RecordMeasurementScreen> {
  bool _loading = false;

  /// First measurement = no existing measurement yet (weight/height from onboarding).
  bool get _isFirstMeasurement =>
      ref.read(appFlowStateProvider)?.measurementComplete != true;

  void _onEnterManually() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManualMeasurementFormScreen(
          isFirstMeasurement: _isFirstMeasurement,
        ),
      ),
    );
  }

  Future<void> _onScanInBody() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source);
    if (xFile == null || !mounted) return;

    final file = File(xFile.path);
    setState(() => _loading = true);
    try {
      await ref.read(measurementRepositoryProvider).importInBodyReport(file);
      
      // Update flow state to reflect measurement completion
      await ref.read(appFlowStateProvider.notifier).checkFlowStatus();
      
      if (mounted) context.go(Routes.home);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            action: SnackBarAction(
              label: 'Enter manually',
              onPressed: () => _onEnterManually(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.spacing24),
                    Text(
                      'Record your body measurements',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(
                      'This helps us personalize your plan.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing32),
                    MeasurementOptionCard(
                      icon: Icons.edit_note,
                      title: 'Enter manually',
                      subtitle: 'Add weight, body fat, and measurements',
                      color: AppColors.primary,
                      onTap: _onEnterManually,
                    ),
                    const SizedBox(height: AppDimensions.spacing12),
                    MeasurementOptionCard(
                      icon: Icons.document_scanner_outlined,
                      title: 'Scan InBody report',
                      subtitle: 'Take a photo of your InBody report',
                      color: AppColors.secondary,
                      onTap: _onScanInBody,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
