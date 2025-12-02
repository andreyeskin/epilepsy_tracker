# 📍 Guía de Uso: Sistema de Beacons Indoor-LBS

## 🎯 Resumen

El sistema de Indoor Location-Based Service (Indoor-LBS) usa beacons Bluetooth Low Energy (BLE) para:
- Detectar en qué habitación se encuentra el usuario
- Evaluar el nivel de riesgo de cada habitación
- Alertar sobre zonas de alto riesgo
- Rastrear tiempo de permanencia en cada espacio

---

## ✅ Funcionalidades Implementadas

### 1. **Escaneo de Beacons BLE** ✅
   - Detección automática de beacons iBeacon (Apple)
   - Escaneo periódico cada 5 segundos
   - Cálculo de distancia basado en RSSI
   - Modo Mock para testing sin hardware real

### 2. **Gestión de Habitaciones** ✅
   - Crear/editar/eliminar habitaciones
   - Asignar nivel de riesgo (Bajo/Medio/Alto)
   - Asociar beacons a habitaciones
   - Iconos personalizables

### 3. **Detección de Ubicación** ✅
   - Dos algoritmos de detección:
     - Por señal más fuerte (RSSI promedio)
     - Por ponderación de distancia
   - Nivel de confianza (0-100%)
   - Detección de cambio de habitación

### 4. **Evaluación de Riesgo** ✅
   - Scoring multi-factor:
     - Nivel de riesgo base de la habitación
     - Tiempo de permanencia
     - (Integración con Fitbit preparada para futuro)
   - Alertas visuales según nivel de riesgo

### 5. **Persistencia de Datos** ✅
   - Beacons guardados en SharedPreferences
   - Habitaciones guardadas localmente
   - Sobrevive al cierre de la app

### 6. **Permisos Runtime** ✅
   - Solicitud automática de permisos Bluetooth
   - Solicitud de permisos de ubicación
   - Compatible con Android 12+

---

## 🚀 Cómo Usar la Funcionalidad

### A. Inicio Rápido con Mock Mode

Para probar sin beacons reales:

1. **Abrir la app**
2. **Ir a Home Screen** → Ver sección "Standort & Sicherheit"
3. **Tap en el widget de ubicación** → Abre Safe Zone Screen
4. **Tab "Übersicht"** muestra:
   - Estado actual del escaneo
   - Habitación actual detectada
   - Nivel de riesgo
   - Tiempo en la habitación
   - Beacons detectados recientemente

5. **Iniciar Mock Mode:**
   - Tap en botón "▶️" (Play) en la AppBar
   - Se solicitan permisos → Aceptar
   - Mock Mode detectará automáticamente 4 beacons simulados

6. **Ver habitaciones:**
   - Tab "Einstellungen"
   - Lista de todas las habitaciones configuradas
   - 4 habitaciones por defecto:
     - 🛋️ Wohnzimmer (Bajo riesgo)
     - 🛏️ Schlafzimmer (Bajo riesgo)
     - 🍳 Küche (Medio riesgo)
     - 🛁 Badezimmer (Alto riesgo)

---

### B. Uso con Beacons Reales

#### 1. **Preparar Hardware**

Necesitas beacons BLE compatibles con formato iBeacon:
- Estimote Beacons
- Kontakt.io Beacons
- Nordic Semiconductor nRF5x
- RadBeacon
- Cualquier beacon programable con iBeacon

**Configuración del Beacon:**
```
Protocolo: iBeacon (Apple 0x004C)
UUID: [Genera un UUID único por beacon]
Major: 1-65535 (opcional)
Minor: 1-65535 (opcional)
TX Power: -59 dBm (típico)
```

#### 2. **Agregar Beacons en la App**

1. **Ir a Safe Zone Screen** → Tab "Einstellungen"
2. **Desactivar Mock Mode** (si está activo):
   - Tap botón toggle "Mock Modus"
3. **Iniciar escaneo real:**
   - Tap botón "▶️" en AppBar
   - Aceptar permisos de Bluetooth y Ubicación
4. **Detectar beacons:**
   - La app escaneará y listará todos los beacons detectados
   - Verás UUID, nombre, RSSI y distancia estimada
5. **Asignar beacon a habitación:**
   - Tap en un beacon detectado
   - Seleccionar habitación de la lista
   - Dar nombre descriptivo al beacon
   - Guardar

#### 3. **Crear Habitaciones Personalizadas**

1. **Tab "Einstellungen"** → Tap "➕ Raum hinzufügen"
2. **Rellenar formulario:**
   - Nombre: ej. "Cocina", "Baño Principal"
   - Icono: Seleccionar de la lista
   - Nivel de Riesgo: Bajo/Medio/Alto
   - Descripción: (opcional)
3. **Guardar**

---

### C. Instalación Física de Beacons

**Recomendaciones:**

1. **Ubicación:**
   - Colocar beacon en el centro de la habitación
   - Altura: 2-2.5m (evita obstrucciones)
   - Evitar superficies metálicas (interfieren señal)
   - No colocar cerca de microondas o Wi-Fi

2. **Cantidad:**
   - Mínimo 1 beacon por habitación pequeña (<20m²)
   - 2-3 beacons para habitaciones grandes (>30m²)
   - Overlap de señal ayuda a mejorar precisión

3. **Calibración:**
   - Caminar por la habitación con la app abierta
   - Verificar que el RSSI sea > -80 dBm en toda el área
   - Ajustar potencia de transmisión si es necesario

---

## 📱 Navegación en la App

### Home Screen
```
┌─────────────────────────┐
│  Standort & Sicherheit  │
├─────────────────────────┤
│ 🛋️ Wohnzimmer          │
│ ⏱️ 15m  ✅ Niedrig     │
│                    →    │  ← Tap para abrir Safe Zone
└─────────────────────────┘
```

### Safe Zone Screen

**Tab 1: Übersicht**
- Estado de escaneo (Activo/Inactivo)
- Habitación actual con icono
- Nivel de riesgo con color
- Tiempo de permanencia
- Lista de beacons detectados recientemente
- Historial de cambios de habitación

**Tab 2: Einstellungen**
- Toggle Mock Mode
- Lista de habitaciones configuradas
- Botón agregar nueva habitación
- Lista de beacons configurados
- Botón escanear nuevos beacons

---

## 🔧 Solución de Problemas

### ❌ "No se detectan beacons"

**Causa posible:** Permisos no otorgados
**Solución:**
1. Configuración del teléfono → Apps → Epilepsy Tracker
2. Permisos → Activar "Ubicación" y "Bluetooth"
3. Reiniciar app

**Causa posible:** Bluetooth desactivado
**Solución:**
1. Activar Bluetooth en el teléfono
2. Reiniciar escaneo en la app

**Causa posible:** Beacons apagados o con batería baja
**Solución:**
1. Verificar LED del beacon (debe parpadear)
2. Reemplazar batería si es necesario
3. Verificar con otra app BLE scanner (nRF Connect)

---

### ❌ "Habitación incorrecta detectada"

**Causa posible:** RSSI muy débil o interferencias
**Solución:**
1. Acercarse más al beacon
2. Verificar que no hay obstáculos metálicos
3. Ajustar `minRssiThreshold` en código (actualmente -90)

**Causa posible:** Beacons con señal similar
**Solución:**
1. Aumentar distancia entre beacons
2. Ajustar potencia de transmisión
3. Usar algoritmo de ponderación (activar en settings)

---

### ❌ "Configuraciones se pierden al cerrar app"

**Ya solucionado** ✅
- Las configuraciones ahora se guardan automáticamente
- Si persiste, revisar permisos de almacenamiento

---

## 🔐 Permisos Necesarios

### Android
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Epilepsy Tracker verwendet Bluetooth, um Ihre Position in Innenräumen zu erkennen.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Epilepsy Tracker benötigt Ihren Standort, um Sicherheitszonen zu überwachen.</string>
```

---

## 📊 Arquitectura Técnica

### Capas

```
presentation/
  └─ providers/
      └─ indoor_location_provider.dart  ← State management
  └─ screens/
      └─ safe_zone_screen.dart          ← UI principal
  └─ widgets/
      └─ beacon_setup_widget.dart       ← Configuración
      └─ room_indicator_widget.dart     ← Indicador compacto
      └─ risk_alert_widget.dart         ← Alertas

domain/
  └─ usecases/
      └─ detect_current_room.dart       ← Algoritmos detección
      └─ evaluate_risk_level.dart       ← Evaluación riesgo

data/
  └─ models/
      └─ beacon_model.dart              ← Modelo beacon
      └─ room_model.dart                ← Modelo habitación
      └─ risk_zone_model.dart           ← Modelo zona riesgo
  └─ repositories/
      └─ beacon_repository.dart         ← Persistencia
  └─ services/
      └─ ble_scanner_service.dart       ← BLE scanning
```

### Flujo de Datos

```
1. Usuario inicia escaneo
   ↓
2. IndoorLocationProvider solicita permisos
   ↓
3. BleScannerService escanea BLE cada 5s
   ↓
4. Beacons detectados → Stream
   ↓
5. DetectCurrentRoom analiza señales
   ↓
6. EvaluateRiskLevel calcula riesgo
   ↓
7. Provider actualiza UI (notifyListeners)
   ↓
8. BeaconRepository persiste cambios
```

---

## 🧪 Testing

### Mock Mode (Sin Hardware)
```dart
// En la app:
provider.setMockMode(true);
provider.startScanning();

// Simula 4 beacons con RSSI variable:
// - beacon_uuid_1: -60 dBm (Wohnzimmer)
// - beacon_uuid_2: -75 dBm (Schlafzimmer)
// - beacon_uuid_3: -70 dBm (Küche)
// - beacon_uuid_4: -85 dBm (Badezimmer)
```

### Testing con App Externa
Usar **nRF Connect** (Android/iOS) para:
1. Verificar que beacons están transmitiendo
2. Ver UUID real del beacon
3. Medir RSSI en diferentes posiciones
4. Verificar formato iBeacon

---

## 🎨 Personalización

### Cambiar Colores de Riesgo

Editar `lib/features/indoor_lbs/data/models/room_model.dart`:

```dart
Color get color {
  switch (this) {
    case RiskLevel.low:
      return Colors.green;      // Cambiar aquí
    case RiskLevel.medium:
      return Colors.orange;     // Cambiar aquí
    case RiskLevel.high:
      return Colors.red;        // Cambiar aquí
  }
}
```

### Ajustar Intervalo de Escaneo

Editar `lib/features/indoor_lbs/presentation/providers/indoor_location_provider.dart`:

```dart
await _scannerService.startScanning(
  scanInterval: 5,  // Segundos entre scans (cambiar aquí)
  scanDuration: 3,  // Duración de cada scan (cambiar aquí)
);
```

### Cambiar Threshold de RSSI

Editar `lib/features/indoor_lbs/presentation/providers/indoor_location_provider.dart`:

```dart
final detectedRoom = _detectCurrentRoom(
  scannedBeacons: beacons,
  minRssiThreshold: -90,  // Cambiar aquí (-70 = más cerca, -100 = más lejos)
);
```

---

## 📈 Próximos Pasos (Futuras Mejoras)

- [ ] Integración con Fitbit (frecuencia cardíaca afecta riesgo)
- [ ] Calibración de RSSI por beacon
- [ ] Background scanning (mantener escaneo con app cerrada)
- [ ] Notificaciones cuando entra a zona de alto riesgo
- [ ] Historial de movimiento (mapa de calor)
- [ ] Exportar datos de ubicación
- [ ] Geofencing (alertas fuera de casa)
- [ ] Modo "Noche" (reduce escaneo para batería)

---

## 📞 Contacto y Soporte

Para reportar bugs o solicitar features:
- GitHub Issues: [Tu repositorio]
- Email: [Tu email]

---

## 📄 Licencia

[Tu licencia]

---

## 🙏 Créditos

- **flutter_blue_plus**: Biblioteca BLE
- **provider**: State management
- **shared_preferences**: Persistencia local

---

**Versión del documento:** 1.0
**Última actualización:** 2025-12-02
**Estado:** ✅ Totalmente funcional
