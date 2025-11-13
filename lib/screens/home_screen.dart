import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/quick_action_card.dart';
import 'seizure_log_screen.dart';
import 'medication_screen.dart';
import 'relaxation_screen.dart';
import 'insights_screen.dart';
import 'fhir_demo_screen.dart';
import '../services/fitbit_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Fitbit Service
  final FitbitService _fitbitService = FitbitService();

  // State Variables
  bool _isAuthenticated = false;
  bool _isLoading = false;
  int? _steps;
  int? _restingHeartRate;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  // Check if user is authenticated with Fitbit
  Future<void> _checkAuthenticationStatus() async {
    final isAuth = await _fitbitService.isAuthenticated();
    setState(() {
      _isAuthenticated = isAuth;
    });
  }

  // Connect to Fitbit
  Future<void> _connectToFitbit() async {
    try {
      // Get authorization URL
      final authUrl = _fitbitService.getAuthorizationUrl();

      // Open browser
      final uri = Uri.parse(authUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Show dialog for code input
        if (!mounted) return;
        final code = await _showCodeInputDialog();

        if (code != null && code.isNotEmpty) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });

          // Exchange code for tokens
          final success = await _fitbitService.exchangeAuthorizationCode(code);

          setState(() {
            _isLoading = false;
          });

          if (success) {
            setState(() {
              _isAuthenticated = true;
            });
            // Load data immediately after authentication
            await _loadFitbitData();
          } else {
            setState(() {
              _errorMessage = 'Fehler beim Verbinden mit Fitbit. Bitte versuchen Sie es erneut.';
            });
          }
        }
      } else {
        setState(() {
          _errorMessage = 'Konnte Browser nicht öffnen.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Fehler: $e';
      });
    }
  }

  // Show dialog for authorization code input
  Future<String?> _showCodeInputDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fitbit Autorisierungscode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bitte geben Sie den Autorisierungscode aus der Fitbit-Webseite ein:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Bestätigen'),
            ),
          ],
        );
      },
    );
  }

  // Load Fitbit data
  Future<void> _loadFitbitData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final steps = await _fitbitService.getStepsToday();
      final heartRate = await _fitbitService.getRestingHeartRate();

      setState(() {
        _steps = steps;
        _restingHeartRate = heartRate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Fehler beim Laden der Daten: $e';
      });
    }
  }

  // Disconnect from Fitbit
  Future<void> _disconnectFitbit() async {
    await _fitbitService.deleteTokens();
    setState(() {
      _isAuthenticated = false;
      _steps = null;
      _restingHeartRate = null;
      _errorMessage = null;
    });
  }

  // Build data card
  Widget _buildDataCard(String title, String? value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8F2EE)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF93),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'Keine Daten',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2A24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

                // Fitbit Aktivitätsdaten
                const Text(
                  'Fitbit Aktivitätsdaten',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2A24),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isAuthenticated) ...[
                        // Not authenticated
                        const Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFF4CAF93)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Verbinden Sie Ihr Fitbit-Konto, um Ihre Aktivitätsdaten zu sehen.',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _connectToFitbit,
                            icon: const Icon(Icons.link),
                            label: const Text('Mit Fitbit verbinden'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF93),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Authenticated
                        if (_isLoading) ...[
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ] else ...[
                          // Data cards
                          _buildDataCard(
                            'Schritte heute',
                            _steps != null ? '$_steps Schritte' : null,
                            Icons.directions_walk,
                          ),
                          const SizedBox(height: 12),
                          _buildDataCard(
                            'Ruhe-Herzfrequenz',
                            _restingHeartRate != null ? '$_restingHeartRate bpm' : null,
                            Icons.favorite,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _loadFitbitData,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Aktualisieren'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF93),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _disconnectFitbit,
                                  icon: const Icon(Icons.link_off),
                                  label: const Text('Trennen'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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
