import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service-Klasse für FHIR-Operationen
/// Verwendet den HAPI FHIR Server (R5): https://hapi.fhir.org/baseR5
class FhirService {
  static const String baseUrl = 'https://hapi.fhir.org/baseR5';

  // ============================================================================
  // USE CASE 1: Smartwatch Monitoring
  // ============================================================================

  /// Erstellt ein Device-Ressource für Smartwatch
  /// Gibt Statuscode und ID zurück
  Future<Map<String, dynamic>> createDevice() async {
    final device = {
      'resourceType': 'Device',
      'status': 'active',
      'deviceName': [
        {
          'name': 'Epilepsie-Tracker Smartwatch',
          'type': 'user-friendly-name'
        }
      ],
      'type': {
        'coding': [
          {
            'system': 'http://snomed.info/sct',
            'code': '706767009',
            'display': 'Patient data recorder'
          }
        ]
      }
    };

    return await _postResource('Device', device);
  }

  /// Erstellt eine Observation für Herzfrequenz
  /// @param bpm - Schläge pro Minute
  /// @param interpretation - z.B. 'normal', 'high', 'low'
  Future<Map<String, dynamic>> createObservationHeartRate(
    int bpm,
    String interpretation
  ) async {
    final observation = {
      'resourceType': 'Observation',
      'status': 'final',
      'category': [
        {
          'coding': [
            {
              'system': 'http://terminology.hl7.org/CodeSystem/observation-category',
              'code': 'vital-signs',
              'display': 'Vital Signs'
            }
          ]
        }
      ],
      'code': {
        'coding': [
          {
            'system': 'http://loinc.org',
            'code': '8867-4',
            'display': 'Heart rate'
          }
        ]
      },
      'valueQuantity': {
        'value': bpm,
        'unit': 'beats/minute',
        'system': 'http://unitsofmeasure.org',
        'code': '/min'
      },
      'interpretation': [
        {
          'coding': [
            {
              'system': 'http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation',
              'code': interpretation == 'high' ? 'H' : (interpretation == 'low' ? 'L' : 'N'),
              'display': interpretation
            }
          ]
        }
      ],
      'effectiveDateTime': DateTime.now().toIso8601String()
    };

    return await _postResource('Observation', observation);
  }

  /// Erstellt eine Observation für körperliche Aktivität (Schritte)
  /// @param steps - Anzahl der Schritte
  Future<Map<String, dynamic>> createObservationActivity(int steps) async {
    final observation = {
      'resourceType': 'Observation',
      'status': 'final',
      'category': [
        {
          'coding': [
            {
              'system': 'http://terminology.hl7.org/CodeSystem/observation-category',
              'code': 'activity',
              'display': 'Activity'
            }
          ]
        }
      ],
      'code': {
        'coding': [
          {
            'system': 'http://loinc.org',
            'code': '41950-7',
            'display': 'Number of steps in 24 hour'
          }
        ]
      },
      'valueQuantity': {
        'value': steps,
        'unit': 'steps',
        'system': 'http://unitsofmeasure.org',
        'code': '{steps}'
      },
      'effectiveDateTime': DateTime.now().toIso8601String()
    };

    return await _postResource('Observation', observation);
  }

  /// Erstellt ein Flag für Anomalien (optional)
  /// @param description - Beschreibung der Anomalie
  Future<Map<String, dynamic>> createFlagAnomaly(String description) async {
    final flag = {
      'resourceType': 'Flag',
      'status': 'active',
      'category': [
        {
          'coding': [
            {
              'system': 'http://terminology.hl7.org/CodeSystem/flag-category',
              'code': 'clinical',
              'display': 'Clinical'
            }
          ]
        }
      ],
      'code': {
        'coding': [
          {
            'system': 'http://snomed.info/sct',
            'code': '439401001',
            'display': 'Diagnosis'
          }
        ],
        'text': description
      }
    };

    return await _postResource('Flag', flag);
  }

  // ============================================================================
  // USE CASE 2: VR-Biofeedback
  // ============================================================================

  /// Erstellt eine Procedure für eine VR-Session
  /// @param scenario - Name des VR-Szenarios
  /// @param start - Startzeit der Session
  /// @param end - Endzeit der Session
  Future<Map<String, dynamic>> createProcedureVRSession(
    String scenario,
    DateTime start,
    DateTime end
  ) async {
    final procedure = {
      'resourceType': 'Procedure',
      'status': 'completed',
      'category': {
        'coding': [
          {
            'system': 'http://snomed.info/sct',
            'code': '225368008',
            'display': 'Biofeedback'
          }
        ]
      },
      'code': {
        'coding': [
          {
            'system': 'http://snomed.info/sct',
            'code': '448901004',
            'display': 'Virtual reality therapy'
          }
        ],
        'text': 'VR-Biofeedback Session: $scenario'
      },
      'performedPeriod': {
        'start': start.toIso8601String(),
        'end': end.toIso8601String()
      }
    };

    return await _postResource('Procedure', procedure);
  }

  /// Erstellt eine Observation für Herzfrequenz-Zeitreihe
  /// @param values - Liste von Herzfrequenz-Werten während der Session
  Future<Map<String, dynamic>> createObservationHeartRateSeries(
    List<int> values
  ) async {
    final observation = {
      'resourceType': 'Observation',
      'status': 'final',
      'category': [
        {
          'coding': [
            {
              'system': 'http://terminology.hl7.org/CodeSystem/observation-category',
              'code': 'vital-signs',
              'display': 'Vital Signs'
            }
          ]
        }
      ],
      'code': {
        'coding': [
          {
            'system': 'http://loinc.org',
            'code': '8867-4',
            'display': 'Heart rate'
          }
        ],
        'text': 'Herzfrequenz-Verlauf während VR-Session'
      },
      'component': values.asMap().entries.map((entry) {
        return {
          'code': {
            'text': 'Messung ${entry.key + 1}'
          },
          'valueQuantity': {
            'value': entry.value,
            'unit': 'beats/minute',
            'system': 'http://unitsofmeasure.org',
            'code': '/min'
          }
        };
      }).toList(),
      'effectiveDateTime': DateTime.now().toIso8601String()
    };

    return await _postResource('Observation', observation);
  }

  /// Erstellt eine Observation für Stresslevel (vorher/nachher)
  /// @param before - Stresslevel vor der Session (0-10)
  /// @param after - Stresslevel nach der Session (0-10)
  Future<Map<String, dynamic>> createObservationStressLevel(
    int before,
    int after
  ) async {
    final observation = {
      'resourceType': 'Observation',
      'status': 'final',
      'category': [
        {
          'coding': [
            {
              'system': 'http://terminology.hl7.org/CodeSystem/observation-category',
              'code': 'survey',
              'display': 'Survey'
            }
          ]
        }
      ],
      'code': {
        'coding': [
          {
            'system': 'http://loinc.org',
            'code': '73985-4',
            'display': 'Exercise stress level'
          }
        ],
        'text': 'Stresslevel VR-Session'
      },
      'component': [
        {
          'code': {
            'text': 'Vor der Session'
          },
          'valueInteger': before
        },
        {
          'code': {
            'text': 'Nach der Session'
          },
          'valueInteger': after
        }
      ],
      'effectiveDateTime': DateTime.now().toIso8601String()
    };

    return await _postResource('Observation', observation);
  }

  // ============================================================================
  // USE CASE 3: Medikamenten-Einnahme
  // ============================================================================

  /// Erstellt ein MedicationStatement für Medikamenten-Einnahme
  /// @param medName - Name des Medikaments
  /// @param time - Zeitpunkt der Einnahme
  Future<Map<String, dynamic>> createMedicationStatement(
    String medName,
    DateTime time
  ) async {
    final medicationStatement = {
      'resourceType': 'MedicationStatement',
      'status': 'recorded',
      'medicationCodeableConcept': {
        'coding': [
          {
            'system': 'http://www.nlm.nih.gov/research/umls/rxnorm',
            'display': medName
          }
        ],
        'text': medName
      },
      'effectiveDateTime': time.toIso8601String(),
      'dateAsserted': DateTime.now().toIso8601String()
    };

    return await _postResource('MedicationStatement', medicationStatement);
  }

  /// Erstellt eine Observation für Medikamenten-Adhärenz
  /// @param percentage - Adhärenz in Prozent (0-100)
  Future<Map<String, dynamic>> createObservationAdherence(double percentage) async {
    final observation = {
      'resourceType': 'Observation',
      'status': 'final',
      'category': [
        {
          'coding': [
            {
              'system': 'http://terminology.hl7.org/CodeSystem/observation-category',
              'code': 'therapy',
              'display': 'Therapy'
            }
          ]
        }
      ],
      'code': {
        'coding': [
          {
            'system': 'http://snomed.info/sct',
            'code': '418633004',
            'display': 'Medication adherence'
          }
        ]
      },
      'valueQuantity': {
        'value': percentage,
        'unit': '%',
        'system': 'http://unitsofmeasure.org',
        'code': '%'
      },
      'effectiveDateTime': DateTime.now().toIso8601String()
    };

    return await _postResource('Observation', observation);
  }

  /// Erstellt eine Task als Erinnerung
  /// @param description - Beschreibung der Aufgabe
  /// @param status - Status ('requested', 'accepted', 'in-progress', 'completed')
  Future<Map<String, dynamic>> createTaskReminder(
    String description,
    String status
  ) async {
    final task = {
      'resourceType': 'Task',
      'status': status,
      'intent': 'order',
      'priority': 'routine',
      'description': description,
      'authoredOn': DateTime.now().toIso8601String()
    };

    return await _postResource('Task', task);
  }

  // ============================================================================
  // Hilfsmethoden
  // ============================================================================

  /// Sendet eine POST-Anfrage an den FHIR-Server
  /// @param resourceType - Typ der FHIR-Ressource
  /// @param resource - JSON-Objekt der Ressource
  /// @return Map mit 'statusCode' und 'id' (falls erfolgreich)
  Future<Map<String, dynamic>> _postResource(
    String resourceType,
    Map<String, dynamic> resource
  ) async {
    try {
      final url = Uri.parse('$baseUrl/$resourceType');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/fhir+json',
          'Accept': 'application/fhir+json',
        },
        body: jsonEncode(resource),
      );

      debugPrint('POST /$resourceType - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final id = responseData['id'] ?? 'Keine ID zurückgegeben';
        debugPrint('Erfolgreich erstellt - ID: $id');

        return {
          'success': true,
          'statusCode': response.statusCode,
          'id': id,
          'location': response.headers['location']
        };
      } else {
        debugPrint('Fehler: ${response.body}');
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': response.body
        };
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }
}
