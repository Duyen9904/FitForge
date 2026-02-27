import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/states/state_widgets.dart';
import '../models/exercise_models.dart';
import '../viewmodels/equipment_list_viewmodel.dart';
import '../widgets/equipment_card.dart';
import '../widgets/equipment_detail_bottom_sheet.dart';

/// Equipment List Screen
/// Browse all equipment grouped by type
class EquipmentListScreen extends ConsumerStatefulWidget {
  const EquipmentListScreen({super.key});

  @override
  ConsumerState<EquipmentListScreen> createState() =>
      _EquipmentListScreenState();
}

class _EquipmentListScreenState extends ConsumerState<EquipmentListScreen> {
  @override
  void initState() {
    super.initState();
    // Load equipment on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(equipmentListViewModelProvider.notifier).loadEquipment();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(equipmentListViewModelProvider.notifier).refresh();
  }

  void _showEquipmentDetail(BuildContext context, Equipment equipment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EquipmentDetailBottomSheet(equipment: equipment),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(equipmentListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment'),
      ),
      body: state.when(
        initial: () => const Center(
          child: Text('Pull to load equipment'),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        loaded: (equipment, groupedEquipment) {
          if (groupedEquipment.isEmpty) {
            return EmptyState(
              icon: Icons.fitness_center,
              title: 'No equipment available',
              description: 'Equipment list is empty',
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              itemCount: groupedEquipment.length,
              itemBuilder: (context, index) {
                final type = groupedEquipment.keys.elementAt(index);
                final items = groupedEquipment[type]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacing8,
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ),

                    // Equipment items
                    ...items.map((eq) => EquipmentCard(
                          equipment: eq,
                          onTap: () => _showEquipmentDetail(context, eq),
                        )),

                    const SizedBox(height: AppDimensions.spacing16),
                  ],
                );
              },
            ),
          );
        },
        error: (message) => ErrorState(
          message: message,
          onRetry: () => ref
              .read(equipmentListViewModelProvider.notifier)
              .loadEquipment(),
        ),
      ),
    );
  }
}
