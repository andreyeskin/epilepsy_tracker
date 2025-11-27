import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/beacon_model.dart';
import '../providers/indoor_location_provider.dart';

/// Widget für die Beacon-Konfiguration
/// Zeigt Liste der konfigurierten Beacons und ermöglicht Hinzufügen/Entfernen
class BeaconSetupWidget extends StatelessWidget {
  const BeaconSetupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IndoorLocationProvider>(
      builder: (context, provider, child) {
        final beacons = provider.configuredBeacons;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Konfigurierte Beacons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Liste der Beacons
            if (beacons.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Keine Beacons konfiguriert.\nFügen Sie einen Beacon hinzu, um zu beginnen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: beacons.length,
                itemBuilder: (context, index) {
                  final beacon = beacons[index];
                  return _BeaconListItem(
                    beacon: beacon,
                    provider: provider,
                    onEdit: () => _showEditBeaconDialog(
                      context,
                      provider,
                      beacon,
                    ),
                    onDelete: () => _confirmDeleteBeacon(
                      context,
                      provider,
                      beacon,
                    ),
                  );
                },
              ),

            const SizedBox(height: 8),

            // Hinzufügen-Button am Ende
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddBeaconDialog(context, provider),
                icon: const Icon(Icons.add),
                label: const Text('Beacon hinzufügen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Zeigt Dialog zum Hinzufügen eines Beacons
  void _showAddBeaconDialog(
    BuildContext context,
    IndoorLocationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => _BeaconEditDialog(
        provider: provider,
        mode: _BeaconEditMode.add,
      ),
    );
  }

  /// Zeigt Dialog zum Bearbeiten eines Beacons
  void _showEditBeaconDialog(
    BuildContext context,
    IndoorLocationProvider provider,
    BeaconModel beacon,
  ) {
    showDialog(
      context: context,
      builder: (context) => _BeaconEditDialog(
        provider: provider,
        mode: _BeaconEditMode.edit,
        existingBeacon: beacon,
      ),
    );
  }

  /// Bestätigt das Löschen eines Beacons
  void _confirmDeleteBeacon(
    BuildContext context,
    IndoorLocationProvider provider,
    BeaconModel beacon,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beacon entfernen'),
        content: Text(
          'Möchten Sie den Beacon "${beacon.name}" wirklich entfernen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.removeBeacon(beacon.uuid);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Beacon "${beacon.name}" entfernt'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );
  }
}

/// List Item für einen Beacon
class _BeaconListItem extends StatelessWidget {
  final BeaconModel beacon;
  final IndoorLocationProvider provider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BeaconListItem({
    required this.beacon,
    required this.provider,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final room = beacon.roomId != null
        ? provider.allRooms.where((r) => r.id == beacon.roomId).firstOrNull
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.bluetooth,
          color: room?.riskLevel.color ?? Colors.grey,
        ),
        title: Text(beacon.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UUID: ${beacon.uuid}'),
            if (room != null)
              Text('Raum: ${room.name}')
            else
              const Text(
                'Kein Raum zugeordnet',
                style: TextStyle(color: Colors.orange),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modus für Beacon-Edit-Dialog
enum _BeaconEditMode { add, edit }

/// Dialog zum Hinzufügen/Bearbeiten eines Beacons
class _BeaconEditDialog extends StatefulWidget {
  final IndoorLocationProvider provider;
  final _BeaconEditMode mode;
  final BeaconModel? existingBeacon;

  const _BeaconEditDialog({
    required this.provider,
    required this.mode,
    this.existingBeacon,
  });

  @override
  State<_BeaconEditDialog> createState() => _BeaconEditDialogState();
}

class _BeaconEditDialogState extends State<_BeaconEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _uuidController;
  String? _selectedRoomId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingBeacon?.name ?? '',
    );
    _uuidController = TextEditingController(
      text: widget.existingBeacon?.uuid ?? '',
    );
    _selectedRoomId = widget.existingBeacon?.roomId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _uuidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rooms = widget.provider.allRooms;

    return AlertDialog(
      title: Text(
        widget.mode == _BeaconEditMode.add
            ? 'Beacon hinzufügen'
            : 'Beacon bearbeiten',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'z.B. Beacon Wohnzimmer',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _uuidController,
              decoration: const InputDecoration(
                labelText: 'UUID',
                hintText: 'Beacon UUID',
              ),
              enabled: widget.mode == _BeaconEditMode.add,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRoomId,
              decoration: const InputDecoration(
                labelText: 'Raum zuordnen',
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Kein Raum'),
                ),
                ...rooms.map((room) {
                  return DropdownMenuItem<String>(
                    value: room.id,
                    child: Row(
                      children: [
                        Icon(room.icon, size: 16),
                        const SizedBox(width: 8),
                        Text(room.name),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRoomId = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _saveBeacon,
          child: const Text('Speichern'),
        ),
      ],
    );
  }

  void _saveBeacon() {
    final name = _nameController.text.trim();
    final uuid = _uuidController.text.trim();

    if (name.isEmpty || uuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte füllen Sie alle Felder aus'),
        ),
      );
      return;
    }

    final beacon = BeaconModel(
      uuid: uuid,
      name: name,
      roomId: _selectedRoomId,
      rssi: 0,
      lastSeen: DateTime.now(),
    );

    widget.provider.configureBeacon(beacon);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Beacon "$name" gespeichert'),
      ),
    );
  }
}
