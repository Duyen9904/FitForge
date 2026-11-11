import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../ui/core/states/state_widgets.dart';
import '../viewmodels/equipment_list_viewmodel.dart';
import 'equipment_card.dart';

/// Content widget for the Equipment tab in the Exercise Library.
/// Displays equipment grouped by type with pull-to-refresh.
class EquipmentTabContent extends ConsumerWidget {
  const EquipmentTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(equipmentListViewModelProvider);

    return state.when(
      initial: () => const Center(
        child: Text('Loading equipment...'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      loaded: (equipment, groupedEquipment) {
        if (groupedEquipment.isEmpty) {
          return const EmptyScreen(
            title: 'No equipment found',
            description: 'No equipment available',
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(equipmentListViewModelProvider.notifier).refresh(),
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
                      _formatEquipmentType(type),
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                    ),
                  ),

                  // Equipment items
                  ...items.map((eq) => EquipmentCard(
                        equipment: eq,
                        onTap: () {
                          context.push(
                            '/equipment/${eq.equipmentId}/exercises',
                            extra: eq.equipmentName,
                          );
                        },
                      )),

                  if (index < groupedEquipment.length - 1)
                    const SizedBox(height: AppDimensions.spacing8),
                ],
              );
            },
          ),
        );
      },
      error: (message) => ErrorState(
        message: message,
        onRetry: () =>
            ref.read(equipmentListViewModelProvider.notifier).loadEquipment(),
      ),
    );
  }

  String _formatEquipmentType(String type) {
    if (type.isEmpty) return type;
    return type[0].toUpperCase() + type.substring(1).toLowerCase();
  }
}
