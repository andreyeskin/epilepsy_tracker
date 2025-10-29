import 'package:flutter/material.dart';

class SeizureLogScreen extends StatelessWidget {
  const SeizureLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anfall protokollieren'),
        backgroundColor: const Color(0xFF4CAF93),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Seizure Log Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}