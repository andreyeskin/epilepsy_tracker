import 'package:flutter/material.dart';
import '../services/fhir_service.dart';

/// Demo-Bildschirm für FHIR-Funktionen
/// Zeigt drei Buttons für die drei Use Cases
class FhirDemoScreen extends StatefulWidget {
  const FhirDemoScreen({super.key});

  @override
  State<FhirDemoScreen> createState() => _FhirDemoScreenState();
}

class _FhirDemoScreenState extends State<FhirDemoScreen> {
  final FhirService _fhirService = FhirService();
  String _resultText = 'Drücken Sie einen Button, um eine FHIR-Aktion auszuführen';
  bool _isLoading = false;

  /// Zeigt Ergebnis in einem Dialog an
  void _showResult(String title, Map<String, dynamic> result) {
    final success = result['success'] ?? false;
    final statusCode = result['statusCode'];
    final id = result['id'];

    setState(() {
      _resultText = '''
$title

Status: ${success ? '✓ Erfolgreich' : '✗ Fehler'}
Statuscode: $statusCode
${id != null ? 'ID: $id' : ''}
''';
    });
  }

  /// USE CASE 1: Smartwatch-Daten senden
  Future<void> _sendSmartwatchData() async {
    setState(() {
      _isLoading = true;
      _resultText = 'Sende Smartwatch-Daten...';
    });

    try {
      // 1. Device erstellen
      debugPrint('\n=== Erstelle Device ===');
      final deviceResult = await _fhirService.createDevice();

      // 2. Herzfrequenz-Observation erstellen
      debugPrint('\n=== Erstelle Herzfrequenz-Observation ===');
      final hrResult = await _fhirService.createObservationHeartRate(78, 'normal');

      // 3. Aktivitäts-Observation erstellen
      debugPrint('\n=== Erstelle Aktivitäts-Observation ===');
      final activityResult = await _fhirService.createObservationActivity(8542);

      // 4. Optional: Anomalie-Flag
      debugPrint('\n=== Erstelle Anomalie-Flag ===');
      final flagResult = await _fhirService.createFlagAnomaly(
        'Ungewöhnliche Herzfrequenz-Variation erkannt'
      );

      // Zusammenfassung anzeigen
      _showResult(
        'Smartwatch-Daten gesendet',
        {
          'success': deviceResult['success'] && hrResult['success'] &&
                     activityResult['success'] && flagResult['success'],
          'statusCode': 'Alle erfolgreich',
          'id': '''
Device: ${deviceResult['id']}
Herzfrequenz: ${hrResult['id']}
Aktivität: ${activityResult['id']}
Flag: ${flagResult['id']}'''
        }
      );
    } catch (e) {
      _showResult('Fehler', {'success': false, 'statusCode': 'Exception', 'error': e.toString()});
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// USE CASE 2: VR-Session starten
  Future<void> _startVRSession() async {
    setState(() {
      _isLoading = true;
      _resultText = 'Starte VR-Session...';
    });

    try {
      final now = DateTime.now();
      final sessionStart = now.subtract(const Duration(minutes: 20));
      final sessionEnd = now;

      // 1. VR-Procedure erstellen
      debugPrint('\n=== Erstelle VR-Procedure ===');
      final procedureResult = await _fhirService.createProcedureVRSession(
        'Entspannungs-Szenario: Strand',
        sessionStart,
        sessionEnd
      );

      // 2. Herzfrequenz-Zeitreihe erstellen
      debugPrint('\n=== Erstelle Herzfrequenz-Zeitreihe ===');
      final hrSeries = [85, 82, 78, 75, 72, 70, 68, 70, 72, 74];
      final hrSeriesResult = await _fhirService.createObservationHeartRateSeries(hrSeries);

      // 3. Stresslevel erstellen
      debugPrint('\n=== Erstelle Stresslevel-Observation ===');
      final stressResult = await _fhirService.createObservationStressLevel(7, 3);

      // Zusammenfassung anzeigen
      _showResult(
        'VR-Session abgeschlossen',
        {
          'success': procedureResult['success'] && hrSeriesResult['success'] &&
                     stressResult['success'],
          'statusCode': 'Alle erfolgreich',
          'id': '''
Procedure: ${procedureResult['id']}
HR-Serie: ${hrSeriesResult['id']}
Stress: ${stressResult['id']}

Stressreduktion: 7 → 3'''
        }
      );
    } catch (e) {
      _showResult('Fehler', {'success': false, 'statusCode': 'Exception', 'error': e.toString()});
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// USE CASE 3: Medikamenten-Einnahme bestätigen
  Future<void> _confirmMedication() async {
    setState(() {
      _isLoading = true;
      _resultText = 'Bestätige Einnahme...';
    });

    try {
      final now = DateTime.now();

      // 1. MedicationStatement erstellen
      debugPrint('\n=== Erstelle MedicationStatement ===');
      final medResult = await _fhirService.createMedicationStatement(
        'Lamotrigin 100mg',
        now
      );

      // 2. Adhärenz-Observation erstellen
      debugPrint('\n=== Erstelle Adhärenz-Observation ===');
      final adherenceResult = await _fhirService.createObservationAdherence(95.5);

      // 3. Task-Erinnerung erstellen
      debugPrint('\n=== Erstelle Task-Erinnerung ===');
      final taskResult = await _fhirService.createTaskReminder(
        'Nächste Einnahme: Lamotrigin 100mg um 20:00 Uhr',
        'requested'
      );

      // Zusammenfassung anzeigen
      _showResult(
        'Medikamenten-Einnahme bestätigt',
        {
          'success': medResult['success'] && adherenceResult['success'] &&
                     taskResult['success'],
          'statusCode': 'Alle erfolgreich',
          'id': '''
MedicationStatement: ${medResult['id']}
Adhärenz: ${adherenceResult['id']}
Task: ${taskResult['id']}

Adhärenz: 95.5%'''
        }
      );
    } catch (e) {
      _showResult('Fehler', {'success': false, 'statusCode': 'Exception', 'error': e.toString()});
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FHIR Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titel
            Text(
              'FHIR-Integration Testumgebung',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Server: hapi.fhir.org/baseR5',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Button 1: Smartwatch-Daten
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _sendSmartwatchData,
              icon: const Icon(Icons.watch),
              label: const Text('Smartwatch-Daten senden'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Button 2: VR-Session
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _startVRSession,
              icon: const Icon(Icons.videogame_asset),
              label: const Text('VR-Session starten'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Button 3: Einnahme bestätigen
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _confirmMedication,
              icon: const Icon(Icons.medication),
              label: const Text('Einnahme bestätigen'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            // Ergebnis-Bereich
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Ergebnis',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const Divider(),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Text(
                          _resultText,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Hinweis
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Details werden in der Konsole ausgegeben',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
