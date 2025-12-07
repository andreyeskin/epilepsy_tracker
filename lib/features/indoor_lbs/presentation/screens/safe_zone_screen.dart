import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/room_model.dart';
import '../providers/indoor_location_provider.dart';
import '../widgets/beacon_setup_widget.dart';
import '../widgets/risk_alert_widget.dart';

/// Hauptscreen für Indoor-Location und Safe-Zone-Überwachung
/// Zeigt Übersicht der Räume, aktuellen Standort und Risiko-Status
class SafeZoneScreen extends StatefulWidget {
  const SafeZoneScreen({super.key});

  @override
  State<SafeZoneScreen> createState() => _SafeZoneScreenState();
}

class _SafeZoneScreenState extends State<SafeZoneScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialisiere Mock-Daten beim ersten Start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<IndoorLocationProvider>();
      provider.initializeMockData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Zone'),
        actions: [
          // Risiko-Indikator in AppBar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: RiskLevelIndicator(),
          ),
          // Scanning Toggle
          Consumer<IndoorLocationProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isScanning ? Icons.stop : Icons.play_arrow,
                ),
                onPressed: () {
                  if (provider.isScanning) {
                    provider.stopScanning();
                  } else {
                    provider.startScanning();
                  }
                },
                tooltip: provider.isScanning
                    ? 'Scanning stoppen'
                    : 'Scanning starten',
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Übersicht', icon: Icon(Icons.home)),
            Tab(text: 'Einstellungen', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Übersicht
          _OverviewTab(),
          // Tab 2: Einstellungen
          _SettingsTab(),
        ],
      ),
    );
  }
}

/// Übersichts-Tab
class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<IndoorLocationProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Risiko-Warnung (falls vorhanden)
              const RiskAlertWidget(),

              const SizedBox(height: 16),

              // Aktueller Standort
              _CurrentLocationCard(provider: provider),

              const SizedBox(height: 24),

              // Raumübersicht
              const Text(
                'Ihre Räume',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Grid der Räume
              _RoomGrid(provider: provider),

              const SizedBox(height: 24),

              // Erkannte Beacons
              if (provider.recentlyDetectedBeacons.isNotEmpty) ...[
                const Text(
                  'Erkannte Beacons',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _DetectedBeaconsList(provider: provider),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Karte mit aktuellem Standort
class _CurrentLocationCard extends StatelessWidget {
  final IndoorLocationProvider provider;

  const _CurrentLocationCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final room = provider.currentRoom;
    final riskLevel = provider.riskLevel;
    final timeInRoom = provider.timeInCurrentRoom;

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              riskLevel.color.withValues(alpha: 0.7),
              riskLevel.color,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktueller Standort',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  room?.icon ?? Icons.location_off,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room?.name ?? 'Unbekannt',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (room != null)
                        Text(
                          'Verweildauer: ${_formatDuration(timeInRoom)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (room != null && room.description != null) ...[
              const SizedBox(height: 12),
              Text(
                room.description!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

/// Grid-Ansicht aller Räume
class _RoomGrid extends StatelessWidget {
  final IndoorLocationProvider provider;

  const _RoomGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    final rooms = provider.allRooms;

    if (rooms.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'Keine Räume konfiguriert.\nGehen Sie zu Einstellungen, um Räume hinzuzufügen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        final isCurrentRoom = provider.currentRoom?.id == room.id;

        return _RoomCard(
          room: room,
          isCurrentRoom: isCurrentRoom,
        );
      },
    );
  }
}

/// Karte für einen einzelnen Raum
class _RoomCard extends StatelessWidget {
  final RoomModel room;
  final bool isCurrentRoom;

  const _RoomCard({
    required this.room,
    required this.isCurrentRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isCurrentRoom ? 8 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isCurrentRoom
              ? Border.all(color: room.riskLevel.color, width: 3)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                room.icon,
                size: 40,
                color: room.riskLevel.color,
              ),
              const SizedBox(height: 8),
              Text(
                room.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: room.riskLevel.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  room.riskLevel.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    color: room.riskLevel.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isCurrentRoom) ...[
                const SizedBox(height: 4),
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.blue,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Liste der erkannten Beacons
class _DetectedBeaconsList extends StatelessWidget {
  final IndoorLocationProvider provider;

  const _DetectedBeaconsList({required this.provider});

  @override
  Widget build(BuildContext context) {
    final beacons = provider.recentlyDetectedBeacons;

    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: beacons.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final beacon = beacons[index];
          final isStrong = beacon.rssi > -70;
          final distance = beacon.getEstimatedDistance();

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isStrong ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.bluetooth,
                color: isStrong ? Colors.green : Colors.orange,
                size: 24,
              ),
            ),
            title: Text(
              beacon.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.signal_cellular_alt,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${beacon.rssi} dBm',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${distance.toStringAsFixed(1)}m',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Einstellungs-Tab
class _SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mock-Modus Toggle
          Consumer<IndoorLocationProvider>(
            builder: (context, provider, child) {
              return Card(
                child: SwitchListTile(
                  title: const Text('Demo-Modus'),
                  subtitle: Text(
                    provider.isMockMode
                        ? 'Simuliert Beacons ohne echte Hardware'
                        : 'Verwendet echte Bluetooth-Beacons',
                  ),
                  value: provider.isMockMode,
                  onChanged: provider.isScanning
                      ? null // Deaktiviert während Scanning läuft
                      : (value) {
                          provider.setMockMode(value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value
                                    ? 'Demo-Modus aktiviert'
                                    : 'Echter Bluetooth-Modus aktiviert',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Beacon-Konfiguration
          const BeaconSetupWidget(),
        ],
      ),
    );
  }
}
