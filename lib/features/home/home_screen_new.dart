import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../screens/seizure_log_screen.dart';
import '../../screens/fhir_demo_screen.dart';
import '../../screens/insights_screen.dart';
import '../../features/medications/medications_screen_new.dart';
import '../../screens/relaxation_screen.dart';
import '../../services/fitbit_service.dart';
import 'widgets/greeting_header.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/medication_preview.dart';
import 'widgets/seizure_preview.dart';

/// Home Screen - Hauptbildschirm der App
/// Refactored version mit modularen Widgets
class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
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
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Authorize using fitbitter
      final success = await _fitbitService.authorize();

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
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Fehler: $e';
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Header
                const GreetingHeader(),
                const SizedBox(height: AppDimensions.spacingXxl),

                // Schnellaktionen
                Text(
                  'Schnellaktionen',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                QuickActionsGrid(
                  onSeizureLog: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SeizureLogScreen(),
                      ),
                    );
                  },
                  onMedication: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MedicationsScreenNew(),
                      ),
                    );
                  },
                  onRelaxation: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RelaxationScreen(),
                      ),
                    );
                  },
                  onInsights: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InsightsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.spacingXxl),

                // FHIR Integration (Entwicklung)
                Text(
                  'Entwicklung & Testing',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                SizedBox(
                  height: 140,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FhirDemoScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingLg),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A5ACD), Color(0xFF8A7BD9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_sync,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: AppDimensions.spacingSm),
                          Text(
                            'FHIR Demo',
                            style: AppTextStyles.h4.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingXs),
                          Text(
                            'FHIR Integration testen',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXxl),

                // Fitbit Aktivitätsdaten
                Text(
                  AppStrings.homeFitbitData,
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                _buildFitbitSection(),
                const SizedBox(height: AppDimensions.spacingXxl),

                // Medication Preview
                MedicationPreview(
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MedicationsScreenNew(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.spacingXxl),

                // Seizure Preview
                SeizurePreview(
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SeizureLogScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFitbitSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
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
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Text(
                    'Verbinden Sie Ihr Fitbit-Konto, um Ihre Aktivitätsdaten zu sehen.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _connectToFitbit,
                icon: const Icon(Icons.link),
                label: const Text('Mit Fitbit verbinden'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
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
              const SizedBox(height: AppDimensions.spacingMd),
              _buildDataCard(
                'Ruhe-Herzfrequenz',
                _restingHeartRate != null ? '$_restingHeartRate bpm' : null,
                Icons.favorite,
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loadFitbitData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Aktualisieren'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
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
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
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
            const SizedBox(height: AppDimensions.spacingMd),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: AppDimensions.spacingSm),
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
    );
  }

  Widget _buildDataCard(String title, String? value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelSmall,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  value ?? 'Keine Daten',
                  style: AppTextStyles.h3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
