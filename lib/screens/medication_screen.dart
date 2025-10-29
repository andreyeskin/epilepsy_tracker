import 'package:flutter/material.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medikamente'),
        backgroundColor: const Color(0xFF4CAF93),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Medication Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}