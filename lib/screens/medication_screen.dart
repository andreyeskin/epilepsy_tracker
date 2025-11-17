import 'package:flutter/material.dart';
import '../core/models/medication.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  // Lista de medicamentos de ejemplo
  List<Medication> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  void _loadMedications() {
    // Medicamentos de ejemplo
    final now = DateTime.now();
    setState(() {
      _medications = [
        Medication(
          id: '1',
          name: 'Lamotrigin',
          dosage: '150mg',
          quantity: 2,
          scheduledDate: now,
          scheduledTime: const TimeOfDay(hour: 8, minute: 0),
          timeOfDay: 'Morgens',
          status: MedicationStatus.pending,
        ),
        Medication(
          id: '2',
          name: 'Levetiracetam',
          dosage: '500mg',
          quantity: 1,
          scheduledDate: now,
          scheduledTime: const TimeOfDay(hour: 12, minute: 0),
          timeOfDay: 'Mittags',
          status: MedicationStatus.taken,
        ),
        Medication(
          id: '3',
          name: 'Lamotrigin',
          dosage: '150mg',
          quantity: 2,
          scheduledDate: now,
          scheduledTime: const TimeOfDay(hour: 20, minute: 0),
          timeOfDay: 'Abends',
          status: MedicationStatus.pending,
        ),
        Medication(
          id: '4',
          name: 'Levetiracetam',
          dosage: '500mg',
          quantity: 1,
          scheduledDate: now,
          scheduledTime: const TimeOfDay(hour: 22, minute: 0),
          timeOfDay: 'Nachts',
          status: MedicationStatus.pending,
        ),
      ];
    });
  }

  void _toggleMedicationStatus(Medication medication) {
    setState(() {
      final index = _medications.indexWhere((m) => m.id == medication.id);
      if (index != -1) {
        final newStatus = medication.status == MedicationStatus.taken
            ? MedicationStatus.pending
            : MedicationStatus.taken;
        _medications[index] = medication.copyWith(
          status: newStatus,
          actualIntakeTime: newStatus == MedicationStatus.taken ? DateTime.now() : null,
        );
      }
    });
  }

  Color _getStatusColor(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.taken:
        return const Color(0xFF4CAF93);
      case MedicationStatus.pending:
        return const Color(0xFFFFA726);
      case MedicationStatus.skipped:
        return const Color(0xFFEF5350);
      case MedicationStatus.delayed:
        return const Color(0xFFFF7043);
    }
  }

  IconData _getTimeIcon(String timeOfDay) {
    switch (timeOfDay) {
      case 'Morgens':
        return Icons.wb_sunny;
      case 'Mittags':
        return Icons.wb_sunny_outlined;
      case 'Abends':
        return Icons.wb_twilight;
      case 'Nachts':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Medikamente'),
        backgroundColor: const Color(0xFF4CAF93),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implementar agregar medicamento
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medikament hinzufügen - In Entwicklung'),
                  backgroundColor: Color(0xFF4CAF93),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header con gradiente
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF93), Color(0xFFA6D5C4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Heutige Einnahmen',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_medications.where((m) => m.status == MedicationStatus.taken).length} von ${_medications.length} genommen',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lista de medicamentos
            Expanded(
              child: _medications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _medications.length,
                      itemBuilder: (context, index) {
                        final medication = _medications[index];
                        return _buildMedicationCard(medication);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Medikamente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fügen Sie Ihre ersten Medikamente hinzu',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    final isTaken = medication.status == MedicationStatus.taken;
    final statusColor = _getStatusColor(medication.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTaken ? const Color(0xFF4CAF93).withOpacity(0.3) : const Color(0xFFE8F2EE),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _toggleMedicationStatus(medication),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono de tiempo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTimeIcon(medication.timeOfDay),
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Información del medicamento
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2A24),
                          decoration: isTaken ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.medication,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${medication.quantity} x ${medication.dosage}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            medication.formattedTime,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          medication.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkbox
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isTaken ? const Color(0xFF4CAF93) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isTaken ? const Color(0xFF4CAF93) : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isTaken
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
