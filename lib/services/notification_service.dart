import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../core/models/medication.dart';

/// Service für die Verwaltung von lokalen Benachrichtigungen
/// Ermöglicht das Planen und Verwalten von Medikamenten-Erinnerungen
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Initialisiert den Notification Service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialisiert Zeitzonen-Datenbank
    tz.initializeTimeZones();

    // Setzt die lokale Zeitzone (Europe/Berlin für Deutschland)
    tz.setLocalLocation(tz.getLocation('Europe/Berlin'));

    // Android Einstellungen
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Einstellungen
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Kombinierte Einstellungen
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialisiert das Plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Behandelt Tap auf Benachrichtigung
  void _onNotificationTapped(NotificationResponse response) {
    // Hier kann später Navigation implementiert werden
    // z.B. zur Medikamentenseite springen
    print('Benachrichtigung angeklickt: ${response.payload}');
  }

  /// Fordert Berechtigungen an (hauptsächlich für iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    // Android 13+ benötigt auch explizite Berechtigung
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      if (granted != null && !granted) return false;
    }

    // iOS Berechtigungen
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Plant eine Benachrichtigung für ein Medikament
  Future<void> scheduleMedicationNotification(Medication medication) async {
    if (!_initialized) await initialize();

    // Berechnet die geplante Zeit
    final scheduledDateTime = tz.TZDateTime(
      tz.local,
      medication.scheduledDate.year,
      medication.scheduledDate.month,
      medication.scheduledDate.day,
      medication.scheduledTime.hour,
      medication.scheduledTime.minute,
    );

    // Prüft ob die Zeit in der Zukunft liegt
    if (scheduledDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print('Medikament ${medication.name} liegt in der Vergangenheit, überspringe Benachrichtigung');
      return;
    }

    // Android Benachrichtigungs-Details
    const androidDetails = AndroidNotificationDetails(
      'medication_reminders', // Channel ID
      'Medikamenten-Erinnerungen', // Channel Name
      channelDescription: 'Erinnerungen für die Einnahme von Medikamenten',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    // iOS Benachrichtigungs-Details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Kombinierte Details
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Plant die Benachrichtigung
    await _notifications.zonedSchedule(
      medication.id.hashCode, // Eindeutige ID basierend auf Medikamenten-ID
      'Medikament einnehmen', // Titel
      '${medication.name} ${medication.dosage} - ${medication.quantity} Tabletten', // Nachricht
      scheduledDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: medication.id, // Für spätere Navigation
    );

    print('Benachrichtigung geplant für ${medication.name} um ${medication.formattedTime}');
  }

  /// Plant Benachrichtigungen für mehrere Medikamente
  Future<void> scheduleMultipleMedications(List<Medication> medications) async {
    for (final medication in medications) {
      if (medication.status == MedicationStatus.pending) {
        await scheduleMedicationNotification(medication);
      }
    }
  }

  /// Storniert eine geplante Benachrichtigung
  Future<void> cancelMedicationNotification(String medicationId) async {
    if (!_initialized) await initialize();

    await _notifications.cancel(medicationId.hashCode);
    print('Benachrichtigung storniert für Medikament: $medicationId');
  }

  /// Storniert alle geplanten Benachrichtigungen
  Future<void> cancelAllNotifications() async {
    if (!_initialized) await initialize();

    await _notifications.cancelAll();
    print('Alle Benachrichtigungen storniert');
  }

  /// Zeigt eine sofortige Test-Benachrichtigung
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'immediate_notifications',
      'Sofortige Benachrichtigungen',
      channelDescription: 'Sofortige Benachrichtigungen für Tests und Bestätigungen',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000, // Eindeutige ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Holt alle ausstehenden Benachrichtigungen
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await initialize();

    return await _notifications.pendingNotificationRequests();
  }

  /// Prüft ob Benachrichtigungen aktiviert sind
  Future<bool> areNotificationsEnabled() async {
    if (!_initialized) await initialize();

    // Android
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled();
      return enabled ?? false;
    }

    // iOS gibt immer true zurück wenn Berechtigungen erteilt wurden
    return true;
  }
}
