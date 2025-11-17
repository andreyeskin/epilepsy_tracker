# RECOMENDACIONES PARA IMPLEMENTACIÓN DE MEDICAMENTOS DATABASE + NOTIFICACIONES

## CONTEXTO
El proyecto actualmente tiene:
- Modelo `Medication` bien definido en `/lib/core/models/medication.dart`
- Base de datos SQLite funcionando para Seizures
- Integración Fitbit completada
- Pantalla `MedicationsScreenNew` con datos de demostración (hardcodeados)

## 1. IMPLEMENTAR PERSISTENCIA DE MEDICAMENTOS (PRÓXIMA FASE)

### 1.1 Crear Tabla en SQLite
```dart
// En SeizureDatabaseService._onCreate()
await db.execute('''
  CREATE TABLE medications (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    dosage TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    scheduledDate TEXT NOT NULL,
    scheduledTime TEXT NOT NULL,
    timeOfDay TEXT NOT NULL,
    status TEXT NOT NULL,
    actualIntakeTime TEXT,
    notes TEXT,
    createdAt TEXT NOT NULL,
    updatedAt TEXT
  )
''');
```

### 1.2 Crear MedicationDatabaseService
```dart
// Nuevo archivo: /lib/services/medication_database_service.dart

class MedicationDatabaseService {
  static final MedicationDatabaseService _instance = 
    MedicationDatabaseService._internal();
  static Database? _database;

  factory MedicationDatabaseService() {
    return _instance;
  }

  MedicationDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Métodos CRUD
  Future<int> insertMedication(Medication medication) async {
    final db = await database;
    return await db.insert(
      'medications',
      medication.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateMedication(Medication medication) async {
    final db = await database;
    final updated = medication.copyWith(notes: medication.notes);
    return await db.update(
      'medications',
      updated.toJson(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  Future<List<Medication>> getMedicationsByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final maps = await db.query(
      'medications',
      where: 'scheduledDate = ?',
      whereArgs: [dateStr],
      orderBy: 'scheduledTime ASC',
    );

    return List.generate(maps.length, (i) {
      return Medication.fromJson(maps[i]);
    });
  }

  Future<List<Medication>> getTodayAndTomorrowMedications() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    final today = await getMedicationsByDate(now);
    final tmrw = await getMedicationsByDate(tomorrow);
    
    return [...today, ...tmrw];
  }
}
```

### 1.3 Integrar en MedicationsScreenNew
```dart
// En MedicationsScreenNew
class _MedicationsScreenNewState extends State<MedicationsScreenNew> {
  final _medicationService = MedicationDatabaseService();
  List<Medication> _medications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final meds = 
        await _medicationService.getTodayAndTomorrowMedications();
      setState(() {
        _medications = meds;
      });
    } catch (e) {
      print('Error loading medications: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMedicationStatus(
    Medication medication,
    MedicationStatus newStatus,
  ) async {
    final updated = medication.copyWith(
      status: newStatus,
      actualIntakeTime: newStatus == MedicationStatus.taken 
        ? DateTime.now() 
        : medication.actualIntakeTime,
    );

    try {
      await _medicationService.updateMedication(updated);
      _loadMedications(); // Recargar
    } catch (e) {
      print('Error updating medication: $e');
    }
  }
}
```

---

## 2. IMPLEMENTAR NOTIFICACIONES

### 2.1 Agregar Dependencias
```yaml
# pubspec.yaml
dependencies:
  flutter_local_notifications: ^16.2.0
  timezone: ^0.9.2
  
  # Para notificaciones mejoradas (opcional)
  awesome_notifications: ^0.9.1
```

### 2.2 Crear NotificationService
```dart
// Nuevo archivo: /lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = 
    NotificationService._internal();
  static final FlutterLocalNotificationsPlugin 
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  // Inicializar
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    // Solicitar permisos en iOS
    await _notificationsPlugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  }

  // Notificación de prueba
  Future<void> showTestNotification() async {
    await _notificationsPlugin.show(
      0,
      'Epilepsy Tracker',
      'Notificación de prueba',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          'Recordatorios de Medicamentos',
          channelDescription: 'Recordatorios para tomar medicamentos',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
        ),
        iOS: DarwinNotificationDetails(
          sound: 'notification_sound.aiff',
        ),
      ),
    );
  }

  // Programar notificación de medicamento
  Future<void> scheduleMedicationReminder({
    required String medicationName,
    required String dosage,
    required TimeOfDay time,
    required int notificationId,
  }) async {
    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Si la hora ya pasó hoy, programar para mañana
    final finalScheduledDate = scheduledDate.isBefore(now)
      ? scheduledDate.add(const Duration(days: 1))
      : scheduledDate;

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      'Recordatorio de Medicamento',
      'Es hora de tomar $medicationName ($dosage)',
      tz.TZDateTime.from(finalScheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          'Recordatorios de Medicamentos',
          channelDescription: 'Recordatorios para tomar medicamentos',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'notification_sound.aiff',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAndAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repetir diariamente
    );
  }

  // Cancelar notificación
  Future<void> cancelNotification(int notificationId) async {
    await _notificationsPlugin.cancel(notificationId);
  }

  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Manejar notificación presionada
  void _handleNotificationResponse(
    NotificationResponse response,
  ) {
    print('Notificación presionada: ${response.payload}');
    // Aquí puedes navegar a la pantalla de medicamentos
  }
}
```

### 2.3 Configurar en Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->

<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- En <application> -->
<service
  android:name="com.dexterous.flutterlocal notifications.FlutterLocalNotificationsService"
  android:foregroundServiceType="dataSync" />
```

### 2.4 Configurar en iOS
```xml
<!-- ios/Runner/Info.plist -->

<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>processing</string>
</array>
```

### 2.5 Inicializar en main.dart
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar notificaciones
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const MyApp());
}
```

### 2.6 Usar en MedicationsScreenNew
```dart
// Cuando se carga un medicamento
Future<void> _loadMedications() async {
  // ... cargar medicamentos ...

  final notificationService = NotificationService();
  
  for (int i = 0; i < _medications.length; i++) {
    final med = _medications[i];
    if (med.status == MedicationStatus.pending && med.isDueToday) {
      await notificationService.scheduleMedicationReminder(
        medicationName: med.name,
        dosage: med.dosage,
        time: med.scheduledTime,
        notificationId: i,
      );
    }
  }
}
```

---

## 3. MEJORAS SUGERIDAS

### 3.1 State Management (Provider)
El proyecto ya tiene `provider` en pubspec.yaml pero no se usa activamente.

```dart
// Crear notifier
class MedicationNotifier extends ChangeNotifier {
  final _dbService = MedicationDatabaseService();
  List<Medication> _medications = [];

  List<Medication> get medications => _medications;

  Future<void> loadMedications() async {
    _medications = 
      await _dbService.getTodayAndTomorrowMedications();
    notifyListeners();
  }

  Future<void> updateStatus(
    Medication med,
    MedicationStatus status,
  ) async {
    final updated = med.copyWith(status: status);
    await _dbService.updateMedication(updated);
    await loadMedications();
  }
}

// Usar en pantalla
class MedicationsScreenNew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicationNotifier()..loadMedications(),
      child: Scaffold(
        body: Consumer<MedicationNotifier>(
          builder: (context, notifier, _) {
            return ListView(
              children: notifier.medications.map((med) {
                return MedicationCard(
                  medication: med,
                  onStatusChanged: (newStatus) {
                    notifier.updateStatus(med, newStatus);
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
```

### 3.2 Sincronización en la Nube
Considerar agregar Firebase/Backend:
- `cloud_firestore` para datos en la nube
- `firebase_auth` para autenticación
- Sincronizar medicamentos y ataques

### 3.3 Exportación de Reportes
```dart
// PDF generation
pdf: ^3.10.0
path_provider: ^2.1.1

// Crear reporte mensual de medicamentos y ataques
```

### 3.4 i18n Completo
```dart
// localization
intl: ^0.20.2 // Ya presente
flutter_localizations:
  sdk: flutter

// Cambiar de hardcoded strings a archivos ARB
```

---

## 4. ESTRUCTURA DE ARCHIVOS PROPUESTA POST-IMPLEMENTACIÓN

```
/lib
  /core
    /models
      ├── medication.dart (ya existe)
      └── seizure.dart (ya existe)
  
  /services
    ├── seizure_database_service.dart (ya existe)
    ├── medication_database_service.dart (NUEVO)
    ├── notification_service.dart (NUEVO)
    ├── fitbit_service.dart (ya existe)
    └── fhir_service.dart (ya existe)
  
  /providers (NUEVO)
    ├── medication_provider.dart
    ├── seizure_provider.dart
    └── notification_provider.dart
  
  /features
    /medications
      ├── medications_screen_new.dart (refactored con provider)
      ├── widgets/
      │   ├── medication_card.dart
      │   ├── medication_form.dart
      │   └── medication_list.dart
      └── repositories/
          └── medication_repository.dart
```

---

## 5. CHECKLIST DE IMPLEMENTACIÓN

```
Fase 1: Persistencia de Medicamentos
  [ ] Crear tabla medications en SQLite
  [ ] Implementar MedicationDatabaseService
  [ ] Crear métodos CRUD
  [ ] Integrar en MedicationsScreenNew
  [ ] Pruebas de inserción/actualización

Fase 2: Notificaciones
  [ ] Agregar dependencias
  [ ] Crear NotificationService
  [ ] Configurar AndroidManifest.xml
  [ ] Configurar Info.plist
  [ ] Solicitar permisos de usuario
  [ ] Programar notificaciones al cargar medicamentos
  [ ] Pruebas en Android e iOS

Fase 3: Mejoras Opcionales
  [ ] Implementar Provider para state management
  [ ] Crear pantalla de agregar medicamentos
  [ ] Editar medicamentos existentes
  [ ] Borrar medicamentos
  [ ] Historial de medicamentos
  [ ] Reportes de adherencia
```

---

## 6. ARCHIVOS RELEVANTES A REVISAR

- `/lib/core/models/medication.dart` - Modelo base
- `/lib/services/seizure_database_service.dart` - Patrón a seguir
- `/lib/features/medications/medications_screen_new.dart` - Pantalla a refactorizar
- `/pubspec.yaml` - Dependencias disponibles

