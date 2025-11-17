# EJEMPLOS DE CÓDIGO - EPILEPSY TRACKER

## 1. MODELO MEDICATION - Ejemplo Completo

### Definición del Modelo:
```dart
// /lib/core/models/medication.dart

class Medication {
  final String id;
  final String name;
  final String dosage;
  final int quantity;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final String timeOfDay;
  MedicationStatus status;
  DateTime? actualIntakeTime;
  String? notes;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.quantity,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.timeOfDay,
    this.status = MedicationStatus.pending,
    this.actualIntakeTime,
    this.notes,
  });

  // Propiedad calculada
  bool get isDueToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  // Propiedad calculada
  bool get isOverdue {
    final now = DateTime.now();
    final scheduled = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
    return now.isAfter(scheduled) && status == MedicationStatus.pending;
  }

  // Serialización para API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'quantity': quantity,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': '${scheduledTime.hour}:${scheduledTime.minute}',
      'timeOfDay': timeOfDay,
      'status': status.toString(),
      'actualIntakeTime': actualIntakeTime?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['scheduledTime'] as String).split(':');
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      quantity: json['quantity'] as int,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      scheduledTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      timeOfDay: json['timeOfDay'] as String,
      status: MedicationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MedicationStatus.pending,
      ),
      actualIntakeTime: json['actualIntakeTime'] != null
          ? DateTime.parse(json['actualIntakeTime'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    int? quantity,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
    String? timeOfDay,
    MedicationStatus? status,
    DateTime? actualIntakeTime,
    String? notes,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      quantity: quantity ?? this.quantity,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      status: status ?? this.status,
      actualIntakeTime: actualIntakeTime ?? this.actualIntakeTime,
      notes: notes ?? this.notes,
    );
  }
}

enum MedicationStatus {
  pending,    // Offen
  taken,      // Genommen
  skipped,    // Übersprungen
  delayed,    // Verspätet
}
```

### Uso en MedicationsScreenNew:
```dart
// Demo de medicamentos para hoy y mañana
final now = DateTime.now();
final tomorrow = now.add(const Duration(days: 1));

_medications = [
  // Hoy - Mañana
  Medication(
    id: '1',
    name: 'Lamotrigin',
    dosage: '150mg',
    quantity: 2,
    scheduledDate: now,
    scheduledTime: const TimeOfDay(hour: 8, minute: 0),
    timeOfDay: AppStrings.medsMorning,
    status: MedicationStatus.taken,
    actualIntakeTime: DateTime(now.year, now.month, now.day, 8, 15),
  ),
  // Hoy - Tarde
  Medication(
    id: '2',
    name: 'Lamotrigin',
    dosage: '150mg',
    quantity: 2,
    scheduledDate: now,
    scheduledTime: const TimeOfDay(hour: 20, minute: 0),
    timeOfDay: AppStrings.medsEvening,
    status: MedicationStatus.pending,
  ),
];
```

---

## 2. SERVICIO DE BD - SeizureDatabaseService

### Singleton Pattern:
```dart
class SeizureDatabaseService {
  static final SeizureDatabaseService _instance = 
    SeizureDatabaseService._internal();
  static Database? _database;

  factory SeizureDatabaseService() {
    return _instance;
  }

  SeizureDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'epilepsy_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE seizures (
        id TEXT PRIMARY KEY,
        dateTime TEXT NOT NULL,
        type INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        severity INTEGER NOT NULL,
        auraSymptoms TEXT,
        symptomsDuring TEXT,
        symptomsAfter TEXT,
        triggers TEXT,
        location TEXT,
        activity TEXT,
        medicationTaken INTEGER NOT NULL,
        medicationName TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');
  }
}
```

### Operaciones CRUD:
```dart
// Insertar
Future<int> insertSeizure(Seizure seizure) async {
  final db = await database;
  return await db.insert(
    'seizures',
    seizure.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Actualizar
Future<int> updateSeizure(Seizure seizure) async {
  final db = await database;
  final updatedSeizure = seizure.copyWith(updatedAt: DateTime.now());
  return await db.update(
    'seizures',
    updatedSeizure.toMap(),
    where: 'id = ?',
    whereArgs: [seizure.id],
  );
}

// Eliminar
Future<int> deleteSeizure(String id) async {
  final db = await database;
  return await db.delete(
    'seizures',
    where: 'id = ?',
    whereArgs: [id],
  );
}
```

### Analytics:
```dart
// Obtener disparadores comunes
Future<Map<String, int>> getMostCommonTriggers() async {
  final seizures = await getAllSeizures();
  final triggerCount = <String, int>{};

  for (final seizure in seizures) {
    for (final trigger in seizure.triggers) {
      triggerCount[trigger] = (triggerCount[trigger] ?? 0) + 1;
    }
  }

  // Ordenar por frecuencia
  final sortedTriggers = Map.fromEntries(
    triggerCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)),
  );

  return sortedTriggers;
}

// Distribución por tipo de ataque
Future<Map<SeizureType, int>> getSeizureTypeDistribution() async {
  final seizures = await getAllSeizures();
  final typeCount = <SeizureType, int>{};

  for (final seizure in seizures) {
    typeCount[seizure.type] = (typeCount[seizure.type] ?? 0) + 1;
  }

  return typeCount;
}
```

---

## 3. FITBIT SERVICE - OAuth2 Flow

### Autorización:
```dart
Future<bool> authorize() async {
  try {
    final authUrl = Uri.https('www.fitbit.com', '/oauth2/authorize', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': 'activity heartrate sleep',
      'expires_in': '604800',
    });

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: callbackScheme,
    );

    final code = Uri.parse(result).queryParameters['code'];
    if (code == null || code.isEmpty) {
      return false;
    }

    // Intercambiar código por tokens
    final tokenResponse = await http.post(
      Uri.parse(tokenUrl),
      headers: {
        'Authorization': 'Basic ${base64Encode(
          utf8.encode('$clientId:$clientSecret')
        )}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'code': code,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
      },
    );

    if (tokenResponse.statusCode == 200) {
      final data = json.decode(tokenResponse.body);

      // Guardar credenciales de forma segura
      await _storage.write(key: _userIdKey, value: data['user_id']);
      await _storage.write(key: _accessTokenKey, value: data['access_token']);
      await _storage.write(key: _refreshTokenKey, value: data['refresh_token']);

      return true;
    }
    return false;
  } catch (e) {
    print('Error during authorization: $e');
    return false;
  }
}
```

### Obtener datos:
```dart
Future<int?> getStepsToday() async {
  try {
    final token = await getAccessToken();
    if (token == null) {
      throw Exception('Nicht authentifiziert');
    }

    final today = DateTime.now();
    final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final response = await http.get(
      Uri.parse('$apiBaseUrl/activities/date/$dateString.json'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final steps = data['summary']?['steps'];
      return steps is int ? steps : null;
    } else if (response.statusCode == 401) {
      // Token expirado, renovar
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        return await getStepsToday(); // Reintentar
      }
    }
    return null;
  } catch (e) {
    print('Error getting steps: $e');
    return null;
  }
}
```

---

## 4. NAVEGACIÓN - main.dart

### Estructura Principal:
```dart
import 'package:flutter/material.dart';
import 'app/theme.dart';
import 'features/home/home_screen_new.dart';
import 'screens/seizure_log_screen.dart';
import 'screens/insights_screen.dart';
import 'features/medications/medications_screen_new.dart';
import 'features/relaxation/relaxation_screen_new.dart';
import 'shared/widgets/app_bottom_nav_bar.dart';
import 'shared/widgets/floating_emergency_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenNew(),           // Índice 0
    const RelaxationScreenNew(),     // Índice 1
    const MedicationsScreenNew(),    // Índice 2
    const InsightsScreen(),          // Índice 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingEmergencyButton(
        onPressed: () {
          // Abre pantalla de registro de ataques
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SeizureLogScreen()),
          );
        },
      ),
    );
  }
}
```

---

## 5. THEME - Material Design 3

### Configuración de Tema:
```dart
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.primaryMedium,
        surface: AppColors.cardBackground,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.cardBackground,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h3,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
```

---

## 6. BOTTOM NAV BAR

```dart
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 24),
          activeIcon: Icon(Icons.home, size: 24),
          label: AppStrings.navHome,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline, size: 24),
          activeIcon: Icon(Icons.favorite, size: 24),
          label: AppStrings.navWellbeing,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication_outlined, size: 24),
          activeIcon: Icon(Icons.medication, size: 24),
          label: AppStrings.navMedications,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined, size: 24),
          activeIcon: Icon(Icons.bar_chart, size: 24),
          label: AppStrings.navInsights,
        ),
      ],
    );
  }
}
```

---

## 7. SEIZURE MODEL - Tipos y Síntomas

```dart
enum SeizureType {
  focal,                    // Fokal
  generalizedTonicClonic,   // Generalisiert tonisch-klonisch
  absence,                  // Absence
  myoclonic,                // Myoklonisch
  tonic,                    // Tonisch
  clonic,                   // Klonisch
  atonic,                   // Atonisch
  unknown,                  // Unbekannt
}

extension SeizureTypeExtension on SeizureType {
  String get displayName {
    switch (this) {
      case SeizureType.focal:
        return 'Fokal';
      case SeizureType.generalizedTonicClonic:
        return 'Generalisiert tonisch-klonisch';
      case SeizureType.absence:
        return 'Absence';
      case SeizureType.myoclonic:
        return 'Myoklonisch';
      case SeizureType.tonic:
        return 'Tonisch';
      case SeizureType.clonic:
        return 'Klonisch';
      case SeizureType.atonic:
        return 'Atonisch';
      case SeizureType.unknown:
        return 'Unbekannt';
    }
  }
}

class SeizureSymptoms {
  static const List<String> duringSymptoms = [
    'Bewusstlosigkeit',
    'Muskelzuckungen',
    'Verkrampfungen',
    'Starrer Blick',
    'Verwirrtheit',
    'Unkontrollierte Bewegungen',
    'Zungenbiss',
    'Schaum vor dem Mund',
    'Sturz',
    'Augenrollen',
  ];

  static const List<String> afterSymptoms = [
    'Müdigkeit',
    'Verwirrtheit',
    'Kopfschmerzen',
    'Muskelschmerzen',
    'Gedächtnisverlust',
    'Schwäche',
    'Übelkeit',
    'Schlafbedürfnis',
    'Orientierungslosigkeit',
  ];

  static const List<String> commonTriggers = [
    'Schlafmangel',
    'Stress',
    'Alkohol',
    'Vergessene Medikation',
    'Flackernde Lichter',
    'Hormonelle Veränderungen',
    'Fieber/Krankheit',
    'Hitze/Dehydration',
    'Körperliche Anstrengung',
    'Koffein',
  ];
}
```

