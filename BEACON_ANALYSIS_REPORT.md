# EPILEPSY TRACKER - BEACON/BLE IMPLEMENTATION ANALYSIS REPORT

**Date:** December 2, 2025  
**Project:** /Users/Daniela/AndroidStudioProjects/epilepsy_tracker  
**Analysis Level:** Very Thorough  
**Focus:** Beacon/BLE Implementation

---

## EXECUTIVE SUMMARY

The epilepsy_tracker project includes a comprehensive Indoor Location-Based Service (Indoor-LBS) module for safe zone monitoring using BLE beacons. While the architecture is well-designed with clean separation of concerns (Clean Architecture pattern), **there are critical issues that prevent it from running "libremente y sin errores" (freely and without errors)**:

1. **CRITICAL: No Runtime Permissions Requested** - App will crash on Android 6+ without Bluetooth permissions
2. **CRITICAL: No Data Persistence** - All beacon configurations lost on app restart
3. **CRITICAL: Resource Leaks in Scanning Loop** - Stream subscriptions not properly cleaned up on errors
4. **HIGH: Unhandled Exception in Scan Callback** - Exceptions in listen() callback will crash the scan operation

---

## FILES ANALYZED

### Core Beacon/BLE Files
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/data/services/ble_scanner_service.dart` (282 lines)
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/data/repositories/beacon_repository.dart` (202 lines)
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/presentation/providers/indoor_location_provider.dart` (249 lines)
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/data/models/beacon_model.dart` (90 lines)
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/data/models/room_model.dart` (129 lines)
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/data/models/risk_zone_model.dart` (140 lines)
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/domain/usecases/detect_current_room.dart` (149 lines)
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/domain/usecases/evaluate_risk_level.dart` (252 lines)
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/presentation/screens/safe_zone_screen.dart` (509 lines)
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/presentation/widgets/beacon_setup_widget.dart` (460 lines)
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/presentation/widgets/risk_alert_widget.dart` (337 lines)
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/presentation/widgets/room_indicator_widget.dart` (219 lines)
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/pubspec.yaml`
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/android/app/src/main/AndroidManifest.xml`
- `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/ios/Runner/Info.plist`

---

## 1. PROJECT STRUCTURE & ARCHITECTURE

### Overall Architecture

The project follows **Clean Architecture** with clear layering:

```
lib/
├── features/
│   ├── indoor_lbs/           # Indoor LBS Module (13 files)
│   │   ├── data/
│   │   │   ├── models/       # BeaconModel, RoomModel, RiskZoneModel
│   │   │   ├── repositories/ # BeaconRepository (in-memory)
│   │   │   └── services/     # BleScannerService (BLE scanning)
│   │   ├── domain/
│   │   │   └── usecases/     # DetectCurrentRoom, EvaluateRiskLevel
│   │   └── presentation/
│   │       ├── providers/    # IndoorLocationProvider (state mgmt)
│   │       ├── screens/      # SafeZoneScreen
│   │       └── widgets/      # BeaconSetupWidget, RiskAlertWidget, etc.
│   ├── home/
│   ├── medications/
│   ├── insights/
│   └── relaxation/
├── screens/
├── services/
└── main.dart
```

### Key Features Implemented

- ✅ **BLE Beacon Detection** - Scans for Bluetooth beacons  
- ✅ **Room Identification** - Determines current room based on beacon signals  
- ✅ **Risk Assessment** - Evaluates danger levels based on room type  
- ✅ **Dwell Time Monitoring** - Tracks time spent in high-risk areas  
- ✅ **Mock Mode** - Simulates beacons for testing without hardware  
- ✅ **User Configuration** - UI to add/edit/remove beacons and rooms  
- ✅ **Real-time Alerts** - Warns user when in high-risk zones  

### Not Implemented

- ❌ **Data Persistence** - No saving to disk/database
- ❌ **Runtime Permissions** - No permission requests
- ❌ **Fitbit Integration** - Code references it but not implemented
- ❌ **Calibration** - RSSI/distance calibration not implemented

---

## 2. BEACON IMPLEMENTATION ANALYSIS

### 2.1 BLE Scanning Implementation

**File:** `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/data/services/ble_scanner_service.dart`

#### Implementation Details

1. **Singleton Pattern** (Lines 10-13)
2. **Two Scanning Modes:**
   - **Mock Mode** (Lines 72-107) - Simulates beacons for testing
   - **Real Scanning** (Lines 143-235) - Uses FlutterBluePlus for actual BLE
3. **Periodic Scanning** (Line 152) - Scans every 5 seconds by default for 3 seconds duration

#### Beacon Detection Protocol: iBeacon Format

Lines 189-200 detect Apple iBeacon format:
- Checks for Apple Company ID: `0x004C` (76 in decimal)
- Validates iBeacon header: `0x02 0x15`
- Extracts 16-byte UUID from manufacturer data

### 2.2 RSSI & Distance Calculation

**File:** `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/data/models/beacon_model.dart` (Lines 57-74)

**Formula:** Friis Free Space Path Loss model with TX power = -59 dBm at 1 meter

**Limitations:** Simplified model that doesn't account for obstacles, multipath, interference

### 2.3 Room/Location Detection

**File:** `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/domain/usecases/detect_current_room.dart`

**Algorithm:**
1. Filters beacons below RSSI threshold (-90 dBm)
2. Maps beacons to rooms using UUID association
3. Selects room with strongest average RSSI signal

**Two Methods:**
1. Simple (Lines 24-75) - Uses average RSSI
2. Weighted (Lines 79-120) - Uses distance-based scoring

### 2.4 Risk Assessment

**File:** `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/domain/usecases/evaluate_risk_level.dart`

Risk scoring algorithm considers:
- Base Risk (Room type)
- Dwell Time Risk
- Heart Rate Risk
- Movement Risk
- Final Score: 0-100 mapped to RiskLevel

---

## 3. CRITICAL ISSUES FOUND

### Critical Issue 1: No Runtime Permissions Requested

**Severity:** CRITICAL  
**Impact:** App crashes on Android 6+  
**Files Affected:**
- `pubspec.yaml` - Lists `permission_handler: ^11.1.0` (UNUSED)
- `lib/features/indoor_lbs/data/services/ble_scanner_service.dart` - Doesn't request permissions
- `lib/features/indoor_lbs/presentation/providers/indoor_location_provider.dart` - Line 66-92

**Problem:** No permission check before calling `startScanning()`

**Required Permissions Not Requested:**
- BLUETOOTH, BLUETOOTH_ADMIN, BLUETOOTH_SCAN, BLUETOOTH_CONNECT
- ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION

---

### Critical Issue 2: Data Not Persisted

**Severity:** CRITICAL  
**Impact:** User configuration lost on app restart  
**File:** `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/data/repositories/beacon_repository.dart` (Lines 14-17)

**Problem:** Pure in-memory storage only:
- Lines 14-16: All data in memory lists/maps
- Lines 103-131: saveBeacon() modifies memory only
- No loadFromDisk() or saveToDisk() methods
- No SharedPreferences or SQLite persistence

---

### Critical Issue 3: Stream Subscription Leak on Error

**Severity:** CRITICAL  
**Impact:** Memory leaks, increased battery drain  
**File:** `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/data/services/ble_scanner_service.dart` (Lines 152-230)

**Problem:**
```dart
Timer.periodic(Duration(seconds: interval), (timer) async {
  try {
    final subscription = FlutterBluePlus.scanResults.listen((results) {
      // No try/catch here - exception could occur
    });
    
    await subscription.cancel();  // ONLY if no exception
    
  } catch (e) {
    // subscription.cancel() NOT CALLED HERE - LEAK!
    print('Fehler beim BLE-Scanning: $e');
  }
});
```

**Issue:** subscription.cancel() only on line 223, not in catch block

---

### Critical Issue 4: Reduce on Potentially Empty List

**Severity:** HIGH  
**Impact:** Crashes with "Empty list" exception  
**File:** `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/domain/usecases/detect_current_room.dart`

**Location 1 (Lines 57-75):**
```dart
final avgRssi = beacons.isEmpty
    ? minRssiThreshold
    : beacons.map((b) => b.rssi).reduce((a, b) => a + b) ~/
          beacons.length;  // Can crash if beacons becomes empty
```

**Location 2 (Lines 138-139):** No isEmpty check at all:
```dart
final avgRssi = roomBeacons.map((b) => b.rssi).reduce((a, b) => a + b) /
    roomBeacons.length;  // Can crash on empty list
```

---

### High Issue 5: No Exception Handling in listen() Callback

**Severity:** HIGH  
**Impact:** Unhandled exception stops scanning  
**File:** `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/data/services/ble_scanner_service.dart` (Lines 167-216)

**Issues:**
- Line 187: substring(0, 8) without length check
- Line 191: Force unwrap [76]! (safe here but risky pattern)
- NO try/catch around entire callback

---

### Medium Issue 6: Debug Logging in Production Code

**Severity:** MEDIUM  
**Impact:** Performance, battery drain  
**File:** `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/lib/features/indoor_lbs/data/services/ble_scanner_service.dart`

**11+ print() statements in scanning loop:**
- Lines 36, 57, 62, 168, 176-181, 198, 212, 215, 228, 232
- Runs every 5 seconds with each beacon
- HUGE log output, impacts performance

---

## 4. DEPENDENCIES ANALYSIS

**File:** `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/pubspec.yaml`

### BLE-Related Packages

| Package | Version | Usage | Status |
|---------|---------|-------|--------|
| flutter_blue_plus | ^1.32.13 | BLE scanning | ✅ Used |
| permission_handler | ^11.1.0 | Runtime permissions | ❌ UNUSED |

### Other Related

- provider: ^6.1.1 (State management)
- sqflite: ^2.3.0 (Database - not used for beacons)
- shared_preferences: ^2.2.2 (Not used for persistence)
- flutter_secure_storage: ^9.2.2 (Not used)

**Issue:** permission_handler declared but NEVER imported or used

---

## 5. PLATFORM CONFIGURATION

### Android

**File:** `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/android/app/src/main/AndroidManifest.xml`

Permissions correctly declared:
- BLUETOOTH, BLUETOOTH_ADMIN, BLUETOOTH_SCAN, BLUETOOTH_CONNECT
- ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION
- bluetooth_le feature

❌ Missing: Runtime permission requests in code

### iOS

**File:** `/Users/Daniela/AndroidStudioProjects/epilepsy_tracker/ios/Runner/Info.plist`

NSBluetoothAlwaysUsageDescription: Correctly declared
NSBluetoothPeripheralUsageDescription: Correctly declared
NSLocationWhenInUseUsageDescription: Correctly declared

❌ Missing: Runtime permission requests in code

---

## 6. CODE QUALITY SUMMARY

### Error Handling
- ✅ Try/catch at top level of scanning
- ❌ No try/catch in listen() callback
- ❌ No exception handling in reduce()
- ❌ No error propagation to UI

### Resource Management
- ✅ StreamController.broadcast() used correctly
- ✅ dispose() methods implemented
- ✅ Timer cancellation in stopScanning()
- ❌ Stream subscription not cancelled on exception
- ❌ No timeout for stuck subscriptions

### Testing & Mocking
- ✅ Good mock mode for testing
- ✅ Realistic mock data generation
- ❌ No unit tests
- ❌ No error injection testing

---

## 7. SPECIFIC CODE PROBLEMS WITH LINE NUMBERS

### Problem 1: Unhandled Exception in Scan Callback

**File:** `ble_scanner_service.dart`  
**Lines:** 167-216

No try/catch around callback code. Any exception stops scan.

### Problem 2: Subscription Not Cancelled on Error

**File:** `ble_scanner_service.dart`  
**Lines:** 152-230

Only line 223 cancels subscription, not in catch block (line 227-229).

### Problem 3: Reduce on Empty List

**File:** `detect_current_room.dart`  
**Lines:** 57-75 and 138-139

Missing isEmpty checks before reduce operations.

### Problem 4: No Permission Request

**File:** `indoor_location_provider.dart`  
**Lines:** 66-92

startScanning() has no permission check.

### Problem 5: Data Not Persisted

**File:** `beacon_repository.dart`  
**Lines:** 14-17, 103-131

Memory-only storage, no disk persistence.

---

## 8. RECOMMENDATIONS FOR FIXES

### Immediate (Critical) - ~1-2 hours total

1. **Add Runtime Permissions** (15 min)
2. **Fix Stream Subscription Leak** (20 min)
3. **Add try/catch in listen() Callback** (10 min)
4. **Fix reduce() Safety** (15 min)
5. **Replace print() with debugPrint()** (30 min)

### High Priority (Within 1 week)

6. **Implement Data Persistence** (1-2 hours)
   - Use SharedPreferences for beacon list
   - Add loadFromStorage() and saveToStorage()

7. **Add Exception Handling UI** (1 hour)
   - Show error snackbars on Bluetooth failures
   - Graceful degradation

---

## 9. CONCLUSION

**Current Status:**
- Architecture: ✅ Well-designed with clean separation
- Feature Completeness: ✅ Core features implemented
- Robustness: ❌ Critical issues prevent reliable operation
- Production Readiness: ❌ Not production-ready

**Time to Production:** ~4-6 hours with all recommended fixes

**Priority Order:**
1. Fix permissions (crashes on Android 6+)
2. Fix stream leak (memory leak)
3. Implement persistence (data loss)
4. Fix exception handling (reliability)

---

Generated: December 2, 2025
