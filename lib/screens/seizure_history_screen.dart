import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/constants/app_text_styles.dart';
import '../models/seizure.dart';
import 'seizure_log_screen.dart';

/// Seizure History Screen - Historial de Anfälle
/// Muestra todos los anfalls registrados en una lista ordenada
class SeizureHistoryScreen extends StatefulWidget {
  const SeizureHistoryScreen({super.key});

  @override
  State<SeizureHistoryScreen> createState() => _SeizureHistoryScreenState();
}

class _SeizureHistoryScreenState extends State<SeizureHistoryScreen> {
  // Demo data - En producción, esto vendría de la base de datos
  final List<Seizure> _seizures = [
    Seizure(
      id: '1',
      dateTime: DateTime.now().subtract(const Duration(hours: 3)),
      type: SeizureType.focal,
      duration: const Duration(seconds: 45),
      severity: 3,
      triggers: ['Stress', 'Schlafmangel'],
      roomName: 'Wohnzimmer',
      notes: 'Kurzer fokaler Anfall am Vormittag',
    ),
    Seizure(
      id: '2',
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
      type: SeizureType.generalizedTonicClonic,
      duration: const Duration(seconds: 90),
      severity: 4,
      triggers: ['Vergessene Medikation'],
      roomName: 'Schlafzimmer',
      medicationTaken: true,
      medicationName: 'Notfall-Diazepam',
      notes: 'Generalisierter Anfall in der Nacht',
    ),
    Seizure(
      id: '3',
      dateTime: DateTime.now().subtract(const Duration(days: 12)),
      type: SeizureType.absence,
      duration: const Duration(seconds: 10),
      severity: 2,
      triggers: ['Flackernde Lichter'],
      notes: 'Kurze Absence, schnell vorbei',
    ),
    Seizure(
      id: '4',
      dateTime: DateTime.now().subtract(const Duration(days: 18)),
      type: SeizureType.focal,
      duration: const Duration(seconds: 60),
      severity: 3,
      triggers: ['Stress'],
      roomName: 'Büro',
      notes: 'Während der Arbeit aufgetreten',
    ),
    Seizure(
      id: '5',
      dateTime: DateTime.now().subtract(const Duration(days: 25)),
      type: SeizureType.myoclonic,
      duration: const Duration(seconds: 5),
      severity: 1,
      triggers: ['Koffein'],
      notes: 'Leichte myoklonische Zuckungen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Anfall-Historial'),
        backgroundColor: const Color(0xFF4CAF93),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SeizureLogScreen(),
                ),
              );
            },
            tooltip: 'Neuen Anfall protokollieren',
          ),
        ],
      ),
      body: _seizures.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Summary
                  _buildStatsCard(),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // Seizure List
                  Text(
                    'Alle Anfälle (${_seizures.length})',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _seizures.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppDimensions.spacingMd),
                    itemBuilder: (context, index) {
                      return _buildSeizureCard(_seizures[index]);
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    final last30Days = _seizures
        .where((s) =>
            s.dateTime.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .length;
    final avgSeverity = _seizures.isEmpty
        ? 0.0
        : _seizures.map((s) => s.severity).reduce((a, b) => a + b) /
            _seizures.length;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF93), Color(0xFF66BB9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF93).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                'Übersicht',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Gesamt', '${_seizures.length}'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem('30 Tage', '$last30Days'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem('Ø Schwere', avgSeverity.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildSeizureCard(Seizure seizure) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: seizure.severityColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showSeizureDetails(seizure);
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Type + Severity
                Row(
                  children: [
                    // Severity Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingMd,
                        vertical: AppDimensions.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: seizure.severityColor,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: Text(
                        'Grad ${seizure.severity}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: Text(
                        seizure.type.displayName,
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMd),

                // Date, Time & Duration
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(
                      seizure.formattedDateTime,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(
                      seizure.formattedDuration,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // Location
                if (seizure.roomName != null) ...[
                  const SizedBox(height: AppDimensions.spacingSm),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: const Color(0xFF4CAF93),
                      ),
                      const SizedBox(width: AppDimensions.spacingXs),
                      Text(
                        seizure.roomName!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF4CAF93),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],

                // Triggers
                if (seizure.triggers.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  Wrap(
                    spacing: AppDimensions.spacingSm,
                    runSpacing: AppDimensions.spacingSm,
                    children: seizure.triggers.map((trigger) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingMd,
                          vertical: AppDimensions.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                          border: Border.all(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        child: Text(
                          trigger,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Emergency Medication
                if (seizure.medicationTaken) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingSm),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSm),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.medication,
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppDimensions.spacingXs),
                        Text(
                          'Notfallmedikation: ${seizure.medicationName ?? "Ja"}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Notes
                if (seizure.notes != null && seizure.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    seizure.notes!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing3Xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing3Xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medical_information_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            Text(
              'Keine Anfälle protokolliert',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              'Deine protokollierten Anfälle werden hier angezeigt',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SeizureLogScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Ersten Anfall protokollieren'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF93),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXl,
                  vertical: AppDimensions.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSeizureDetails(Seizure seizure) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.radiusXxl),
            topRight: Radius.circular(AppDimensions.radiusXxl),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: AppDimensions.spacingMd),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingXl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.spacingMd),
                          decoration: BoxDecoration(
                            color: seizure.severityColor.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusMd),
                          ),
                          child: Icon(
                            Icons.medical_information,
                            color: seizure.severityColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                seizure.type.displayName,
                                style: AppTextStyles.headlineSmall,
                              ),
                              Text(
                                seizure.formattedDateTime,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXl),

                    // Details
                    _buildDetailRow('Schweregrad', 'Grad ${seizure.severity}'),
                    _buildDetailRow('Dauer', seizure.formattedDuration),
                    if (seizure.roomName != null)
                      _buildDetailRow('Ort', seizure.roomName!),
                    if (seizure.triggers.isNotEmpty)
                      _buildDetailRow('Auslöser', seizure.triggers.join(', ')),
                    if (seizure.medicationTaken)
                      _buildDetailRow(
                        'Notfallmedikation',
                        seizure.medicationName ?? 'Ja',
                      ),
                    if (seizure.notes != null && seizure.notes!.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacingMd),
                      Text(
                        'Notizen',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      Text(
                        seizure.notes!,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
