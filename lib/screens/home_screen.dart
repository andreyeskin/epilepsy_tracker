import 'package:flutter/material.dart';
import '../widgets/quick_action_card.dart';
import 'seizure_log_screen.dart';
import 'medication_screen.dart';
import 'relaxation_screen.dart';
import 'insights_screen.dart';
import 'fhir_demo_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
              Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF93), Color(0xFFA6D5C4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hallo!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Wie geht es dir heute?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Schnellaktionen
                const Text(
                  'Schnellaktionen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2A24),
                  ),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    QuickActionCard(
                      icon: Icons.add_circle_outline,
                      title: 'Anfall protokollieren',
                      description: 'Schnelle Dokumentation',
                      color: const Color(0xFF8FD1B7),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SeizureLogScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionCard(
                      icon: Icons.medication,
                      title: 'Medikamente',
                      description: 'Einnahme bestätigen',
                      color: const Color(0xFFA6D5C4),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MedicationScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionCard(
                      icon: Icons.self_improvement,
                      title: 'Ruheraum',
                      description: 'Entspannung & Atmung',
                      color: const Color(0xFF3A8C78),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RelaxationScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionCard(
                      icon: Icons.notifications_active,
                      title: 'Einblicke',
                      description: 'Deine Fortschritte',
                      color: const Color(0xFF4CAF93),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InsightsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // FHIR Integration (Entwicklung)
                const Text(
                  'Entwicklung & Testing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2A24),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 140,
                  child: QuickActionCard(
                    icon: Icons.cloud_sync,
                    title: 'FHIR Demo',
                    description: 'FHIR Integration testen',
                    color: const Color(0xFF6A5ACD),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FhirDemoScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Nächste Medikamente
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nächste Medikamente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2A24),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MedicationScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Alle anzeigen',
                        style: TextStyle(
                          color: Color(0xFF4CAF93),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMedicationItem(
                        'Lamotrigin 150mg',
                        '2 Tabletten',
                        '08:00',
                      ),
                      const Divider(height: 24, color: Color(0xFFE8F2EE)),
                      _buildMedicationItem(
                        'Levetiracetam 500mg',
                        '1 Tablette',
                        '20:00',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Letzte Anfälle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Letzte Anfälle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2A24),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Alle anzeigen',
                        style: TextStyle(
                          color: Color(0xFF4CAF93),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSeizureItem(
                        'Fokal',
                        '45 Sekunden, Schweregrad 3',
                        'Heute, 09:15',
                      ),
                      const Divider(height: 24, color: Color(0xFFE8F2EE)),
                      _buildSeizureItem(
                        'Generalisiert',
                        '90 Sekunden, Schweregrad 4',
                        '15.10.2025',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationItem(String name, String dosage, String time) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF3A8C78),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.access_time,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                dosage,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4CAF93),
          ),
        ),
      ],
    );
  }

  Widget _buildSeizureItem(String type, String details, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                details,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}