/// Deutsche UI-Texte für die gesamte App
/// Zentralisiert alle Text-Strings für einfache Wartung und i18n
class AppStrings {
  AppStrings._(); // Private constructor für Utility-Klasse

  // App
  static const String appName = 'Epilepsie Tracker';

  // Navigation
  static const String navHome = 'Start';
  static const String navWellbeing = 'Wohlbefinden';
  static const String navMedications = 'Medikamente';
  static const String navInsights = 'Einblicke';

  // Home Screen
  static const String homeGreeting = 'Hallo!';
  static const String homeSubtitle = 'Wie geht es dir heute?';
  static const String homeQuickActions = 'Schnellaktionen';
  static const String homeNextMeds = 'Nächste Medikamente';
  static const String homeRecentSeizures = 'Letzte Anfälle';
  static const String homeViewAll = 'Alle anzeigen';
  static const String homeFitbitData = 'Fitbit Aktivitätsdaten';

  // Quick Actions
  static const String quickActionSeizureLog = 'Anfall protokollieren';
  static const String quickActionSeizureDesc = 'Schnelle Dokumentation';
  static const String quickActionMedication = 'Medikamente';
  static const String quickActionMedicationDesc = 'Einnahme bestätigen';
  static const String quickActionRelaxation = 'Ruheraum';
  static const String quickActionRelaxationDesc = 'Entspannung & Atmung';
  static const String quickActionInsights = 'Einblicke';
  static const String quickActionInsightsDesc = 'Deine Fortschritte';

  // Medications Screen
  static const String medsTitle = 'Medikamente';
  static const String medsToday = 'Heute';
  static const String medsTomorrow = 'Morgen';
  static const String medsAddNew = '+ Medikament hinzufügen';
  static const String medsTaken = 'GENOMMEN';
  static const String medsTake = 'NEHMEN';
  static const String medsTablets = 'Tabletten';
  static const String medsMorning = 'Morgens';
  static const String medsEvening = 'Abends';

  // Wellbeing Screen
  static const String wellbeingTitle = 'Wohlbefinden';
  static const String wellbeingDate = 'Datum';
  static const String wellbeingSleep = 'Schlafqualität';
  static const String wellbeingStress = 'Stress-Level';
  static const String wellbeingMood = 'Allgemeinbefinden';
  static const String wellbeingNotes = 'Besondere Ereignisse';
  static const String wellbeingSave = 'Speichern';
  static const String wellbeingSaved = 'Erfolgreich gespeichert!';

  // Insights Screen
  static const String insightsTitle = 'Einblicke';
  static const String insightsMonth = 'Monat';
  static const String insightsSeizuresTitle = 'Anfälle diesen Monat';
  static const String insightsTotal = 'Gesamt';
  static const String insightsAverage = 'Ø';
  static const String insightsChange = 'Veränderung';
  static const String insightsTriggersTitle = 'Auslöser-Verteilung';
  static const String insightsAdherenceTitle = 'Medikamenten-Adhärenz';
  static const String insightsAchievement = '7 Tage perfekte Medikamenten-Einnahme! ⭐';
  static const String insightsExport = 'Bericht exportieren';
  static const String insightsShare = 'Mit Arzt teilen';

  // Relaxation Screen
  static const String relaxationTitle = 'Ruheraum';
  static const String relaxationChooseScene = 'Wähle deine Szene';
  static const String relaxationDuration = 'Dauer';
  static const String relaxationDuration5 = '5 Min';
  static const String relaxationDuration10 = '10 Min';
  static const String relaxationDuration15 = '15 Min';
  static const String relaxationDurationFree = 'Frei';
  static const String relaxationStart = 'Starten';
  static const String relaxationBreathing = 'Atemtechnik 4-7-8';
  static const String relaxationBreathingDesc = 'Atme 4 Sekunden ein, halte 7 Sekunden, atme 8 Sekunden aus.';

  // Seizure Screen
  static const String seizureTitle = 'Anfall-Protokoll';
  static const String seizureAddNew = 'Neuen Anfall dokumentieren';
  static const String seizureType = 'Anfallstyp';
  static const String seizureSeverity = 'Schweregrad';
  static const String seizureDuration = 'Dauer';
  static const String seizureTrigger = 'Auslöser';
  static const String seizureNotes = 'Notizen';
  static const String seizureSave = 'Speichern';
  static const String seizureTypeFocal = 'Fokal';
  static const String seizureTypeGeneralized = 'Generalisiert';

  // Common
  static const String cancel = 'Abbrechen';
  static const String confirm = 'Bestätigen';
  static const String save = 'Speichern';
  static const String delete = 'Löschen';
  static const String edit = 'Bearbeiten';
  static const String close = 'Schließen';
  static const String loading = 'Laden...';
  static const String error = 'Fehler';
  static const String success = 'Erfolgreich';
  static const String noData = 'Keine Daten verfügbar';
  static const String retry = 'Erneut versuchen';

  // Emergency
  static const String emergencyCall = 'Notruf';
  static const String emergencyQuickLog = 'Schnelles Protokoll';

  // Errors
  static const String errorGeneric = 'Ein Fehler ist aufgetreten';
  static const String errorNetwork = 'Netzwerkfehler';
  static const String errorSaving = 'Fehler beim Speichern';
  static const String errorLoading = 'Fehler beim Laden';
}
