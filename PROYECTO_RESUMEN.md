# ANÁLISIS DETALLADO: EPILEPSY TRACKER (Flutter)

## IMPORTANTE: Este es un proyecto FLUTTER, NO React Native

El proyecto utiliza:
- **Framework**: Flutter (Dart)
- **Versión SDK**: Dart 3.9.2+
- **Arquitectura**: Feature-driven + MVC

---

## 1. SCREENS/COMPONENTES EXISTENTES

### Pantallas Principales (Navegación Bottom Tab):
1. **HomeScreenNew** (`/features/home/home_screen_new.dart`)
   - 455 líneas
   - Pantalla de inicio con datos de Fitbit
   - Widgets: GreetingHeader, QuickActionsGrid, MedicationPreview, SeizurePreview

2. **RelaxationScreenNew** (`/features/relaxation/relaxation_screen_new.dart`)
   - 356 líneas
   - Técnicas de relajación y respiración

3. **MedicationsScreenNew** (`/features/medications/medications_screen_new.dart`)
   - 381 líneas
   - Gestión de medicamentos del día/mañana
   - Estado: Pendiente, Tomado, Omitido, Retrasado

4. **InsightsScreenNew** (`/features/insights/insights_screen_new.dart`)
   - 248 líneas
   - Gráficos: Frecuencia de ataques, Adherencia, Disparadores
   - Insignias de logros

### Pantallas Adicionales:
5. **SeizureLogScreen** (`/screens/seizure_log_screen.dart`)
   - 729 líneas (mayor archivo del proyecto)
   - Registro detallado de ataques epilépticos
   - Acceso vía botón flotante de emergencia

6. **FHIRDemoScreen** (`/screens/fhir_demo_screen.dart`)
   - 329 líneas
   - Demo de integración FHIR estándar médico

7. **WellbeingScreen** (`/features/wellbeing/wellbeing_screen.dart`)
   - 353 líneas
   - Registro de bienestar, sueño, estrés

---

## 2. BASE DE DATOS IMPLEMENTADA

### SQLite Local (sqflite)
**Servicio**: `SeizureDatabaseService` (`/services/seizure_database_service.dart`)
- 230 líneas
- Singleton pattern
- Base de datos: `epilepsy_tracker.db`

**Tabla Creada**:
```sql
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
  medicationTaken INTEGER,
  medicationName TEXT,
  notes TEXT,
  createdAt TEXT NOT NULL,
  updatedAt TEXT
)
```

**Métodos Disponibles**:
- CRUD: insertSeizure, updateSeizure, deleteSeizure, getSeizure
- Queries: getAllSeizures, getSeizuresByDateRange, getCurrentMonthSeizures, getRecentSeizures
- Analytics: getMostCommonTriggers, getSeizureTypeDistribution, getAverageSeverity

### Almacenamiento Seguro (flutter_secure_storage)
- Credenciales Fitbit: access_token, refresh_token, user_id

### Preferencias Compartidas (shared_preferences)
- Configuración de la app

---

## 3. ESTRUCTURA DE CARPETAS Y ARQUITECTURA

### Arquitectura General:
```
Clean Architecture + Feature-Driven Design

/lib
  /app          → Configuración global (tema)
  /core         → Núcleo: constantes y modelos base
  /models       → Modelos de datos (Seizure, FitbitData)
  /services     → Lógica de negocio (BD, API)
  /features     → Pantallas feature-specific
  /screens      → Legacy screens
  /shared       → Widgets reutilizables
  /widgets      → Widgets compartidos
```

### Patrón de Proyecto:
- **Modular**: Cada feature tiene su carpeta con widgets
- **Reutilizable**: Shared widgets y constantes centralizadas
- **Separación de responsabilidades**: Services para lógica de negocio

### Archivos Clave de Configuración:
1. **pubspec.yaml** - Dependencias y configuración
2. **app/theme.dart** - Material Design 3 Theme
3. **core/constants/** - Colores, estilos, textos (alemán)

---

## 4. SISTEMA DE NAVEGACIÓN

### Navegación Principal: MaterialApp + StatefulWidget
`/main.dart`:
```dart
MainNavigationScreen (Stateful)
├─ _screens[4]:
│  ├─ [0] HomeScreenNew
│  ├─ [1] RelaxationScreenNew
│  ├─ [2] MedicationsScreenNew
│  └─ [3] InsightsScreen (legacy)
├─ AppBottomNavBar
└─ FloatingEmergencyButton
```

### Navegación Secundaria:
- **Navigator.push()** para abrir SeizureLogScreen
- **MaterialPageRoute()** para transiciones

### Bottom Navigation Bar:
- Home (casa): Home
- Wellbeing (corazón): Relajación/Bienestar
- Medications (píldora): Medicamentos
- Insights (gráfico): Análisis

---

## 5. MODELO DE DATOS - MEDICAMENTOS

### Clase: `Medication` (`/core/models/medication.dart`)

```dart
class Medication {
  final String id;
  final String name;           // ej. "Lamotrigin"
  final String dosage;         // ej. "150mg"
  final int quantity;          // número de tabletas
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final String timeOfDay;      // "Morgens", "Mittags", "Abends", "Nachts"
  MedicationStatus status;     // pending, taken, skipped, delayed
  DateTime? actualIntakeTime;
  String? notes;
}

enum MedicationStatus {
  pending,    // Aún no tomado
  taken,      // Tomado
  skipped,    // Omitido
  delayed,    // Retrasado
}
```

**Métodos Importantes**:
- `copyWith()` - Inmutabilidad
- `toJson()/fromJson()` - Serialización
- `isDueToday` - Propiedad calculada
- `isOverdue` - Propiedad calculada
- `formattedTime` - Getter para mostrar hora

**Demo Data**:
- Lamotrigin 150mg, 2 tabletas
- Horarios: Mañana (8:00), Tarde (20:00)

---

## 6. MODELO DE DATOS - ATAQUES

### Clase: `Seizure` (`/models/seizure.dart`)

```dart
class Seizure {
  final String id;
  final DateTime dateTime;
  final SeizureType type;      // 8 tipos diferentes
  final Duration duration;
  final int severity;          // 1-5
  final String? auraSymptoms;
  final List<String> symptomsDuring;
  final List<String> symptomsAfter;
  final List<String> triggers;
  final String? location;
  final String? activity;
  final bool medicationTaken;
  final String? medicationName;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
}

enum SeizureType {
  focal, generalizedTonicClonic, absence,
  myoclonic, tonic, clonic, atonic, unknown
}

class SeizureSymptoms {
  static const duringSymptoms = [...]    // 10 síntomas
  static const afterSymptoms = [...]     // 9 síntomas
  static const commonTriggers = [...]    // 10 disparadores comunes
}
```

**Métodos**:
- `toMap()/fromMap()` - Serialización BD
- `severityColor` - Getter para UI
- `formattedDuration` - Formato legible
- `formattedDateTime` - Formato legible

---

## 7. NOTIFICACIONES

### Estado Actual: ❌ NO IMPLEMENTADO

**Búsqueda en código**:
- Solo referencias UI en `home_screen.dart` y widgets
- No hay paquetes de notificación en pubspec.yaml
- No hay servicio de notificaciones

**Lo que sería necesario para implementar**:
- `flutter_local_notifications` - Notificaciones locales
- `awesome_notifications` (alternativa)
- Configuración en AndroidManifest.xml e Info.plist
- Servicio para programar recordatorios de medicamentos

---

## 8. INTEGRACIONES EXTERNAS

### Fitbit API
**Servicio**: `FitbitService` (`/services/fitbit_service.dart`)

**Credenciales**:
```
clientId: '23TQK4'
clientSecret: 'f7cd25a75d12571fc486a915458feae9'
redirectUri: 'epilepsytracker://fitbit/callback'
```

**Métodos**:
- `authorize()` - OAuth2 flow con FlutterWebAuth2
- `isAuthenticated()` - Verifica si hay tokens
- `getStepsToday()` - Pasos del día
- `getRestingHeartRate()` - Frecuencia cardíaca
- `_refreshAccessToken()` - Renovación de token

**Datos Almacenados**:
- user_id, access_token, refresh_token (secure storage)

### FHIR Demo
**Servicio**: `FHIRService` (`/services/fhir_service.dart`)
- 444 líneas
- Estándar médico internacional para datos sanitarios

---

## 9. DEPENDENCIAS PRINCIPALES

```yaml
# Estado
provider: ^6.1.1

# API & HTTP
http: ^1.2.0

# Base de datos
sqflite: ^2.3.0
path_provider: ^2.1.1

# Gráficos
fl_chart: ^0.66.0

# Fecha/Hora
intl: ^0.20.2

# Almacenamiento
shared_preferences: ^2.2.2
flutter_secure_storage: ^9.2.2

# Fitbit
fitbitter: ^2.0.6
flutter_web_auth_2: ^4.1.0
url_launcher: ^6.3.1

# Utilidades
image_picker: ^1.0.5
permission_handler: ^11.1.0
shimmer: ^3.0.0
```

---

## 10. ARCHIVOS MÁS RELEVANTES

| Archivo | Líneas | Propósito |
|---------|--------|----------|
| seizure_log_screen.dart | 729 | Registro de ataques (mayor) |
| home_screen.dart | 685 | Home legacy |
| insights_screen.dart | 630 | Analytics legacy |
| seizure.dart | 269 | Modelo Seizure |
| fitbit_service.dart | 238 | Integración Fitbit |
| seizure_database_service.dart | 230 | Acceso a BD |
| medication.dart | 149 | Modelo Medication |

---

## 11. CARACTERÍSTICAS IMPLEMENTADAS

✅ Registro de ataques epilépticos
✅ Seguimiento de medicamentos
✅ Integración Fitbit (pasos, FC)
✅ Analytics/Insights (gráficos)
✅ Wohlbefinden (bienestar)
✅ Relajación/respiración
✅ Base de datos local SQLite
✅ Tema Material Design 3
✅ Interfaz alemana
✅ FHIR demo
✅ Almacenamiento seguro OAuth2

❌ Notificaciones/recordatorios
❌ Sincronización en la nube
❌ Exportación de informes
❌ Manejo de datos de medicamentos persistente
❌ State management (Provider no usado activamente)

---

## 12. CONSIDERACIONES TÉCNICAS

- **Refactoring en progreso**: Coexisten pantallas legacy y nuevas
- **Testing**: Carpeta /test vacía
- **i18n**: Todo hardcodeado en alemán (en app_strings.dart)
- **Error handling**: Básico, sin manejo centralizado
- **Logging**: Solo print() statements
