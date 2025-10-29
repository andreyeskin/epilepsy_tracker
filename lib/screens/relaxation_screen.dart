import 'package:flutter/material.dart';

class RelaxationScreen extends StatelessWidget {
  const RelaxationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relaxation'),
        backgroundColor: const Color(0xFF4CAF93),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Relaxation Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}